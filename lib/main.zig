const std = @import("std");
const allocator = std.heap.page_allocator;
const eql = std.mem.eql;

const worker = @import("workers-zig");
const String = worker.String;
const FetchContext = worker.FetchContext;

const basicHandler = @import("routes/basic.zig").basicHandler;

// NOTE:
// https://github.com/ziglang/zig/issues/3160
// until @asyncCall WASM support is implemented we use a double-up function
export fn fetchEvent (ctxID: u32) void {
  // build the fetchContext
  const ctx = FetchContext.init(ctxID) catch {
    String.new("Unable to prepare a FetchContext.").throw();
    return;
  };
  // Build the async frame:
  const frame = allocator.create(@Frame(_fetchEvent)) catch {
      ctx.throw(500, "Unable to prepare a frame.");
      return undefined;
  };
  frame.* = async _fetchEvent(ctx);
  // tell the context about the frame for later destruction
  ctx.frame.* = frame;
}

fn _fetchEvent (ctx: *FetchContext) callconv(.Async) void {
  const path = ctx.path;

  if (eql(u8, "basic", path)) return basicHandler(ctx);

  // If we make it here, throw.
  ctx.throw(500, "Route does not exist.");
}
