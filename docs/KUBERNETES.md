## Running random_thoughts_api in Kubernetes

:eyes: Currently only Docker Desktop on Mac is supported

### Running in Kubernetes on Docker Desktop on Mac

**Prerequisites:**
 * Docker Desktop installed
 * Kubernetes enabled (this requires a restart of Docker Desktop)

#### Starting

1. In a browser, navigate to the [nginx ingress deploy site](https://kubernetes.github.io/ingress-nginx/deploy/), for example on a Mac...
   ```bash
   open https://kubernetes.github.io/ingress-nginx/deploy/
   ```

3. Follow the instructions for deploying the ingress controller, for example...
   ```
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
   ```

4. Wait for the `ingress-nginx-controller-*` to be `Running`...
   ```
   kubectl get pods --namespace=ingress-nginx
   ```

   > :guide_dog: You can also use the [`k9s`](https://k9scli.io/)
   > command line cluster management tool...
   > ```
   > k9s -n ingress-nginx
   > ```

5. Change directory to the manifest files...
   ```bash
   cd k8s/development/app
   ```

6. Apply the manifest files...
   ```
   kubectl apply -f .
   ```

7. Wait for the random-thoughts-api pods to come up...
   ```
   kubectl get pods --namespace=random-thoughts-api
   ```

   > :guide_dog: and in `k9s`...
   > ```
   > k9s -n random-thoughts-api
   > ```

   The pods may fail and even go into `CrashLoopBackOff`
   as they come up and "find" each other.  This is normal
   for 2 or so restarts.

8. The `random_thoughts_api` application is now available
   at http://localhost/

#### Stopping

1. Delete the manifest configuration...
   ```
   kubectl delete -f .
   ```

2. Delete the ingress controller, for example...
   ```
   kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml
   ```

   > :hourglass: It may take awhile for this command to complete
