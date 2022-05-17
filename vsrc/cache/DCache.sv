`ifndef __DCACHE_SV
`define __DCACHE_SV

`ifdef VERILATOR
`include "include/common.sv"
/* You should not add any additional includes in this file */
`endif

module DCache 
	import common::*; #(
		/* You can modify this part to support more parameters */
		/* e.g. OFFSET_BITS, INDEX_BITS, TAG_BITS */
		parameter WORDS_PER_LINE = 16,
        parameter ASSOCIATIVITY = 2,
        parameter SET_NUM = 8,
        parameter ALIGN_BYTES = 8
	)(
	input logic clk, reset,

	input  dbus_req_t  dreq,
    output dbus_resp_t dresp,
    output cbus_req_t  creq,
    input  cbus_resp_t cresp
);

`ifndef REFERENCE_CACHE

	/* TODO: Lab3 Cache */

    // params
    localparam OFFSET_BITS = $clog2(WORDS_PER_LINE);
    localparam INDEX_BITS = $clog2(SET_NUM);
    localparam ALIGN_BITS = $clog2(ALIGN_BYTES);
    localparam TAG_BITS = $bits(word_t) - INDEX_BITS - OFFSET_BITS - ALIGN_BITS;
    localparam POSITION_BITS = $clog2(ASSOCIATIVITY);

    localparam type offset_t = logic [OFFSET_BITS-1:0];
    localparam type index_t = logic [INDEX_BITS-1:0];
    localparam type tag_t = logic [TAG_BITS-1:0];
    localparam type position_t = logic [POSITION_BITS-1:0];

    function offset_t get_offset(addr_t addr);
        return addr[OFFSET_BITS+ALIGN_BITS-1:ALIGN_BITS];
    endfunction

    function index_t get_index(addr_t addr);
        return addr[INDEX_BITS+OFFSET_BITS+ALIGN_BITS-1:OFFSET_BITS+ALIGN_BITS];
    endfunction

    function tag_t get_tag(addr_t addr);
        return addr[TAG_BITS+INDEX_BITS+OFFSET_BITS+ALIGN_BITS-1:INDEX_BITS+OFFSET_BITS+ALIGN_BITS];
    endfunction

    localparam type state_t = enum logic[1:0] {
        INIT, FETCH, WRITEBACK, UNCACHED
    };

    typedef struct packed {
        u1 valid;
        u1 dirty;
        tag_t tag;
    } meta_t;
    typedef meta_t [ASSOCIATIVITY-1:0] meta_set_t;
    typedef logic [ASSOCIATIVITY-1:0] meta_strobe_t;

    /* These info won't change in a transaction */
    tag_t tag;
    index_t index;
    offset_t offset;
    assign {tag, index, offset} = {get_tag(dreq.addr), get_index(dreq.addr), get_offset(dreq.addr)};

    state_t state, state_nxt;
    offset_t counter, counter_nxt;

    // Meta RAM
    struct packed {
        logic en;
        meta_strobe_t strobe;
        meta_set_t wmeta;
    } meta_ram;
    meta_set_t meta_ram_rmeta;

    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram;
    word_t ram_rdata;

    logic hit_data_ok;
    position_t hit_position;

    logic empty;
    position_t empty_position;

    // Choose meta
    RAM_SinglePort #(
		.ADDR_WIDTH(INDEX_BITS),
		.DATA_WIDTH($bits(meta_set_t)),
		.BYTE_WIDTH($bits(meta_t)),
		.READ_LATENCY(0)
    ) ram_meta (
        .clk(clk), .en(meta_ram.en),
        .addr(index),
        .strobe(meta_ram.strobe),
        .wdata(meta_ram.wmeta),
        .rdata(meta_ram_rmeta)
    );

    // Calculate whether hit
    always_comb begin
        hit_data_ok = '0;
        hit_position = '0;
        for (int i = 0; i < ASSOCIATIVITY; ++i) begin
            if (meta_ram_rmeta[i].tag == tag && meta_ram_rmeta[i].valid) begin
                hit_data_ok = '1;
                hit_position = position_t'(i);
                break;
            end
        end
        hit_data_ok &= (dreq.valid & (state == INIT));
    end
    // always_ff @(posedge clk) begin if (state == INIT && empty) $display("%x", dreq.addr); end

    // Calculate whether empty
    always_comb begin
        empty = '0;
        empty_position = '0;
        for (int i = 0; i < ASSOCIATIVITY; ++i) begin
            if (~meta_ram_rmeta[i].valid) begin
                empty = '1;
                empty_position = position_t'(i);
                break;
            end
        end
    end

    // PLRU
    // the replaced position of this algorithm won't change if not hit
    position_t replaced_position [SET_NUM-1:0];
    for (genvar i = 0; i < SET_NUM; ++i) begin
        wire hit = hit_data_ok && (index == index_t'(i));
        int age [ASSOCIATIVITY-1:0], age_nxt [ASSOCIATIVITY-1:0];
        for (genvar j = 0; j < ASSOCIATIVITY; ++j) begin
            always_comb begin
                age_nxt[j] = age[j];
                if (hit) begin
                    age_nxt[j] = {1'b0, age_nxt[j][31:1]};
                    if (hit_position == position_t'(j)) begin
                        age_nxt[j][31] = 1'b1;
                    end
                end
            end
        end
        always_comb begin
            replaced_position[i] = '0;
            for (int j = 0; j < ASSOCIATIVITY; ++j) begin
                if (age[j] < age[replaced_position[i]]) begin
                    replaced_position[i] = position_t'(j);
                end
            end
            if (hit) begin
                replaced_position[i] = hit_position;
            end
        end
        always_ff @(posedge clk) begin
            if (reset) begin
                for (int j = 0; j < ASSOCIATIVITY; ++j) begin
                    age[j] <= '0;
                end
            end else begin
                age <= age_nxt;
            end
        end
    end

    position_t position; // TODO
    always_comb begin
        if (hit_data_ok) begin
            position = hit_position;
        end else
        if (empty) begin
            position = empty_position;
        end else begin
            position = replaced_position[index];
        end
    end

    // Write meta
    // int pos = int'(position);
    always_comb begin
        meta_ram = '0;
        unique case (state)
            INIT: if (hit_data_ok) begin
                meta_ram.en = 1;
                meta_ram.strobe[position] = 1'b1;
                meta_ram.wmeta[position].valid = 1;
                meta_ram.wmeta[position].dirty = |(dreq.strobe) | meta_ram_rmeta[position].dirty;
                meta_ram.wmeta[position].tag = tag;
            end

            FETCH: begin
                meta_ram.en = 1;
                meta_ram.strobe[position] = 1'b1;
                meta_ram.wmeta[position].valid = cresp.last;
                meta_ram.wmeta[position].dirty = 0;
                meta_ram.wmeta[position].tag = tag;
            end

            default: begin
                
            end
        endcase
    end

    // Write data
    always_comb begin
        ram = '0;
        unique case (state)
            INIT: if (|(dreq.strobe) & hit_data_ok) begin
                ram.en = 1;
                ram.strobe = dreq.strobe;
                ram.wdata = dreq.data;
            end

            FETCH: begin
                ram.en = 1;
                ram.strobe = '1;
                ram.wdata = cresp.data;
            end

            default: begin
                
            end
        endcase
    end

    offset_t cur;
    assign cur = hit_data_ok ? offset : counter;

    // Choose data
    RAM_SinglePort #(
		.ADDR_WIDTH(POSITION_BITS + INDEX_BITS + OFFSET_BITS),
		.DATA_WIDTH($bits(word_t)),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
    ) ram_data (
        .clk(clk), .en(ram.en),
        .addr({position, index, cur}),
        .strobe(ram.strobe),
        .wdata(ram.wdata),
        .rdata(ram_rdata)
    );
    // always_ff @(posedge clk) begin if (ram_wdata != 64'hcccccccc_cccccccc)$display("%x", ram_rdata); end

    // the FSM
    always_comb begin
        state_nxt = state;
        counter_nxt = counter;
        unique case (state)
            INIT: if (dreq.valid) begin
                if (dreq.addr[31]) begin
                    counter_nxt = 0;
                    if (~hit_data_ok) begin
                        if (empty | ~meta_ram_rmeta[position].dirty) begin
                            state_nxt = FETCH;
                        end else begin
                            state_nxt = WRITEBACK;
                        end
                    end
                end else begin
                    state_nxt = UNCACHED;
                end
            end
            FETCH: begin
                if (cresp.ready) begin
                    counter_nxt = counter + 1;
                end
                if (cresp.last) begin
                    state_nxt = INIT;
                end
            end
            WRITEBACK: begin
                if (cresp.ready) begin
                    counter_nxt = counter + 1;
                end
                if (cresp.last) begin
                    state_nxt = FETCH;
                end
            end
            UNCACHED: if (cresp.last) begin
                state_nxt = INIT;
            end
            default: begin
                
            end
        endcase
    end

    // DBus driver
    wire dbus_ok = ((state == INIT) & dreq.addr[31] & hit_data_ok) | ((state == UNCACHED) & cresp.last);
    assign dresp.addr_ok = dbus_ok;
    assign dresp.data_ok = dbus_ok;
    assign dresp.data = dbus_ok ? ((state == INIT) ? ram_rdata : cresp.data) : '0;

    // CBus driver
    assign creq.valid = (state != INIT) & dreq.valid;
    assign creq.is_write = (state == WRITEBACK);
    assign creq.size = MSIZE8; // TODO
    assign creq.addr = (state == WRITEBACK) ? {meta_ram_rmeta[position].tag, index, 7'b0} : {tag, index, 7'b0};
    assign creq.strobe = (state == WRITEBACK) ? '1 : '0;
    assign creq.data = (state == UNCACHED) ? dreq.data : ram_rdata;
    assign creq.len = (state == UNCACHED) ? MLEN1 : AXI_BURST_LEN;
    assign creq.burst = (state == UNCACHED) ? AXI_BURST_FIXED : AXI_BURST_INCR;

    // flip-flop
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= INIT;
            counter <= '0;
        end else begin
            state <= state_nxt;
            counter <= counter_nxt;
        end
    end


`else

	typedef enum u2 {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

	// typedefs
    typedef union packed {
        word_t data;
        u8 [7:0] lanes;
    } view_t;

    typedef u4 offset_t;

    // registers
    state_t    state /* verilator public_flat_rd */;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.
    offset_t   offset;

    // wires
    offset_t start;
    assign start = dreq.addr[6:3];

    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram;
    word_t ram_rdata;

    always_comb
    unique case (state)
    FETCH: begin
        ram.en     = 1;
        ram.strobe = 8'b11111111;
        ram.wdata  = cresp.data;
    end

    READY: begin
        ram.en     = 1;
        ram.strobe = req.strobe;
        ram.wdata  = req.data;
    end

    default: ram = '0;
    endcase

    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
	) ram_inst (
        .clk(clk), .en(ram.en),
        .addr(offset),
        .strobe(ram.strobe),
        .wdata(ram.wdata),
        .rdata(ram_rdata)
    );

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == FLUSH;
    assign creq.is_write = state == FLUSH;
    assign creq.size     = MSIZE8;
    assign creq.addr     = req.addr;
    assign creq.strobe   = 8'b11111111;
    assign creq.data     = ram_rdata;
    assign creq.len      = MLEN16;
	assign creq.burst	 = AXI_BURST_INCR;

    // the FSM
    always_ff @(posedge clk)
    if (~reset) begin
        unique case (state)
        IDLE: if (dreq.valid) begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end else begin
        state <= IDLE;
        {req, offset} <= '0;
    end

`endif

endmodule

`endif
