import fastifyPlugin from 'fastify-plugin'
import { StorageBackendAdapter, createStorageBackend } from '../../storage/backend'
import { Storage } from '../../storage'
import { StorageKnexDB } from '../../storage/database'

declare module 'fastify' {
  interface FastifyRequest {
    storage: Storage
    backend: StorageBackendAdapter
  }
}

export const storage = fastifyPlugin(async (fastify) => {
  const storageBackend = createStorageBackend()

  fastify.decorateRequest('storage', undefined)
  fastify.addHook('preHandler', async (request) => {
    const database = new StorageKnexDB(request.db, {
      tenantId: request.tenantId,
      host: request.headers['x-forwarded-host'] as string,
    })
    request.backend = storageBackend
    request.storage = new Storage(storageBackend, database)
  })
})
