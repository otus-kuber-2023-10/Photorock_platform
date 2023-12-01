// this file has the baseline default parameters
{
  components: {
    deployment: {
      name: 'cartservice',
      image: 'gcr.io/google-samples/microservices-demo/cartservice:v0.1.3',
      containerPort: 7070,
      env: [
        { name: 'REDIS_ADDR', value: 'redis-cart:6379', },
        { name: 'PORT', value: std.toString(7070), },
        { name: 'LISTEN_ADDR', value: '0.0.0.0', },
      ],
      reqcpu: '100m', 
      reqmemory: '64Mi',
      limcpu: '200m',
      limmemory: '128Mi',
    },
    service: {
      name: 'cartservice',
      port: 7070,
      targetPort: self.port,
    },
  },
}
