![Test And Deploy](https://github.com/cryptoPickle/go-serverless/workflows/Test%20And%20Deploy/badge.svg)

Create a new service

``make create-service name=myservice``


### Bumping
Manual Bumping: Any commit message that includes ```#major, #minor, or #patch``` will trigger the respective version bump. If two or more are present, the highest-ranking one will take precedence.

### Deploying All

Any commit message that include ```[ redeploy-all ]``` will trigger redeploying everything