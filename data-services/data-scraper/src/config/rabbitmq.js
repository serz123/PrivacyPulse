import amqp from 'amqplib'

let connection
let channel

/**
 * Establishes a connection to RabbitMQ
 *
 * @param {string} connectionString - The RabbitMQ connection string (e.g., amqp://username:password@host:port).
 * @returns {Promise<amqp.Channel>} Resolves to the AMQP channel
 */
export const connectToRabbitMQ = async (connectionString) => {
  try {
    console.log('Connecting to RabbitMQ...')
    connection = await amqp.connect(connectionString)
    channel = await connection.createChannel()
    console.log('Connected to RabbitMQ.')

    // Error and close event listeners
    connection.on('error', (err) => {
      console.log(`RabbitMQ connection error: ${err.message}`)
    })

    connection.on('close', () => {
      console.log('RabbitMQ connection closed.')
    })

    // Graceful shutdown
    for (const signalEvent of ['SIGINT', 'SIGTERM']) {
      process.on(signalEvent, async () => {
        try {
          await channel.close()
          await connection.close()
          console.log(`RabbitMQ connection closed through ${signalEvent}.`)
          process.exit(0)
        } catch (err) {
          console.log(`Error while closing RabbitMQ connection: ${err.message}`)
          process.exit(1)
        }
      })
    }
  } catch (err) {
    console.log(`Error connecting to RabbitMQ: ${err.message}`)
    throw err
  }
}

/**
 * Getter za AMQP kanal.
 *
 * @returns {amqp.Channel} Returns channel
 */
export const getRabbitMQChannel = () => {
  if (!channel) {
    throw new Error('RabbitMQ channel is not initialized. Call connectToRabbitMQ first.')
  }
  return channel
}
