.. _ChatQnA_deploy_xeon:


Single Node On-Prem Deployment: XEON Scalable Processors
########################################################

e.g use case:
Should provide context for selecting between vLLM and TGI.

.. tabs::

   .. tab:: Deploy with Docker compose with vLLM

      TODO: The section must cover how the above said archi can be implemented
      with vllm mode, or the serving model chosen. Show an Basic E2E end case
      set up with 1 type of DB for e.g Redis based on what is already covered in
      chatqna example( others can be called out or referenced to accordingly),
      Show how to use one SOTA model, for llama3 and others with a sample
      configuration. The use outcome must demonstrate on a real use case showing
      both productivity and performance. For consistency, lets use the OPEA
      documentation for RAG use cases

      Sample titles:

      1. Overview
         Talk a few lines of what is expected in this tutorial. Forer.g. Redis
         db used and llama3 model run to showcase an e2e use case using OPEA and
         vllm.
      #. Pre-requisites
         Includes cloning the repos, pulling the necessary containers if
         available (UI, pipeline ect), setting the env variables like proxys,
         getting access to model weights, get tokens on hf, lg etc. sanity
         checks if needed. Etc.
      #. Prepare (Building / Pulling)  Docker images
         a) This step will involve building/pulling ( maybe in future) relevant docker images with step-by-step process along with sanity check in the end
         #) If customization is needed, we show 1 case of how to do it

      #. Use case setup

         This section will include how to  get the data and other
         dependencies needed, followed by all the micoservice envs ready. Use
         this section to also talk about how to set other models if needed, how
         to use other dbs etc

      #. Deploy chatqna use case based on the docker_compose

         This should cover the steps involved in starting the microservices
         and megaservies, also explaining some key highlights of what’s covered
         in the docker compose. Include sanity checks as needed. Each
         microservice/megaservice start command along with what it does and the
         expected output will be good to add

      #. Interacting with ChatQnA deployment. ( or navigating chatqna workflow)

         This section to cover how to use a different machine to interact and
         validate the microservice and walk through how to navigate each
         services. For e.g uploading local document for data prep and how to get
         answers? Customer will be interested in getting the output for a query,
         and a time also measure the quality of the model and the perf metrics(
         Health and Statistics to also be covered). Please check if these
         details can also be curled in the endpoints. Is uploading templates
         available now?. Custom  template is available today

         Show all the customization available and features

      #. Additional Capabilities (optional)
         Use case specific features to call out

      #. Launch the UI service
         Show steps how to launch the UI and a sample screenshot of query and output


   .. tab:: Deploy with docker compose with TGI

      This section will be similar to vLLM.  Should be worth trying to single source.
