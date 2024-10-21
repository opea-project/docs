# Тестовий файл розмітки з перехресними посиланнями

Ця папка містить колекцію маніфест файлів Kubernetes для розгортання сервісу ChatQnA на масштабованих вузлах. Вона включає комплексний [інструмент для бенчмаркінгу] (/GenAIEval/evals/benchmark/README.md), який дозволяє проводити аналіз пропускної здатності для оцінки продуктивності виводу.

Ми створили [BKC маніфест](https://github.com/opea-project/GenAIExamples/tree/main/ChatQnA/benchmark) для одновузлового, двовузлового і чотиривузлового кластерів K8s. Для того, щоб застосувати, нам потрібно перевірити і налаштувати деякі значення.

Для тестування продуктивності використовується [інструмент бенчмарку](https://github.com/opea-project/GenAIEval/tree/main/evals/benchmark). Нам потрібно встановити інструмент бенчмарку на головному вузлі Kubernetes, яким є k8s-master.

У цьому документі описано процес розгортання програми CodeGen з використанням трубопроводу мікросервісів [GenAIComps](https://github.com/opea-project/GenAIComps.git) на сервері Intel Gaudi2. Кроки включають створення образів Docker, розгортання контейнера за допомогою Docker Compose і виконання сервісів для інтеграції мікросервісів, таких як `llm`. Незабаром ми опублікуємо образи Docker на Docker Hub, що ще більше спростить процес розгортання цього сервісу.

Встановіть GMC у кластері Kubernetes, якщо ви цього ще не зробили, виконавши кроки з розділу «Початок роботи» на сторінці [Встановлення GMC](https://github.com/opea-project/GenAIInfra/tree/main/microservices-connector#readme). Незабаром ми опублікуємо образи на Docker Hub, після чого збірки не знадобляться, що ще більше спростить встановлення.

Якщо ви отримуєте помилки на кшталт «Доступ заборонено», спочатку [перевірте мікросервіс](https://github.com/opea-project/GenAIExamples/tree/main/CodeGen/docker_compose/intel/cpu/xeon#validate-microservices).

Оновіть базу знань через локальний файл [nke-10k-2023.pdf](https://github.com/opea-project/GenAIComps/blob/main/comps/retrievers/redis/data/nke-10k-2023.pdf)

Будь ласка, зверніться до [Xeon README](/GenAIExamples/AudioQnA/docker_compose/intel/cpu/xeon/README.md) або [Gaudi README](/GenAIExamples/AudioQnA/docker_compose/intel/hpu/gaudi/README.md) для створення образів OPEA. Незабаром вони також будуть доступні на Docker Hub для спрощення використання.

Ось [посилання](https://github.com/opea-project/GenAIComps/blob/main/comps/reranks/tei/Dockerfile) на файл Docker.

У цьому прикладі ви можете ознайомитися з інструментами yaml і python-файлів. Для більш детальної інформації, будь ласка, зверніться до розділу «Provide your own tools» інструкції [тут](https://github.com/opea-project/GenAIComps/tree/main/comps/agent/langchain#5-customize-agent-strategy).

Ось інше [посилання](https://github.com/opea-project/GenAIExamples/blob/main/ChatQnA/ui/docker/Dockerfile.react) для вивчення.

Ось гарний [Docker Xeon README](/GenAIExamples/DocSum/docker_compose/intel/cpu/xeon/README.md) і з посиланням на розділ [Docker Xeon README](/GenAIExamples/DocSum/docker_compose/intel/cpu/xeon/README.md#section)

І посилання на python-файл [finetune_config](https://github.com/opea-project/GenAIComps/blob/main/comps/finetuning/finetune_config.py), щоб було цікавіше.

Ось [issue](https://github.com/opea-project/GenAIExamples/issues/763)
і [Actions](https://github.com/opea-project/GenAIExamples/actions) також.
Можна також перевірити [PR](https://github.com/opea-project/GenAIExamples/pulls)
і [Projects](https://github.com/opea-project/GenAIExamples/projects).

У примітках до випуску ви знайдете [88b3c1](https://github.com/opea-project/GenAIInfra/commit/88b3c108e5b5e3bfb6d9346ce2863b69f70cc2f1) посилання на комміти.
