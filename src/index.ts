/**
 * Learn more at https://developers.cloudflare.com/workers/
 */
import { Router } from 'itty-router'
import { zigFetch, getZigWorker } from 'workers-zig'

const router = Router()
// js route
router.get('/', () => new Response('Hello from JS!'))
// zig route using zig's FetchMap
router.post('/basic', zigFetch<Env>('basic'))

// ** ZIG HEAP **
// for testing purposes
// return the heap to ensure it's cleaned up
/** @internal */
export function zigHeap (): Array<any> {
  const worker = getZigWorker()
  return [...worker.heap]
}

export default {
  fetch: router.handle
}
