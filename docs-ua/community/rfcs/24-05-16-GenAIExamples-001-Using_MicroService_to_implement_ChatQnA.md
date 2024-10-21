# 24-05-16 GenAIExamples-001 Using MicroService to Implement ChatQnA

## Автори
[lvliang-intel](https://github.com/lvliang-intel), [ftian1](https://github.com/ftian1), [hshen14](https://github.com/hshen14), [Spycsh](https://github.com/Spycsh), [letonghan](https://github.com/letonghan)

## Статус
На розгляді

## Мета
Цей RFC має на меті представити мікросервісний дизайн OPEA та продемонструвати його застосування до розширеного покоління пошуку (RAG). Мета полягає у вирішенні проблеми розробки гнучкої архітектури для корпоративних додатків штучного інтелекту за допомогою мікросервісного підходу. Цей підхід полегшує розгортання, дозволяючи одному або декільком мікросервісам формувати мегасервіс. Кожен мегасервіс взаємодіє зі шлюзом, дозволяючи користувачам отримувати доступ до сервісів через кінцеві точки, відкриті шлюзом. Архітектура є загальною, і RAG є першим прикладом, який ми хочемо застосувати.

## Мотивація
Використання архітектури мікросервісів при розробці корпоративних додатків штучного інтелекту дає значні переваги, особливо при обробці великих обсягів запитів користувачів. Розбиваючи систему на модульні мікросервіси, кожен з яких відповідає за певну функцію, ми можемо досягти значного підвищення продуктивності завдяки можливості масштабування окремих компонентів. Така масштабованість гарантує, що система може ефективно управляти високим попитом, розподіляючи навантаження між кількома екземплярами кожного мікросервісу за потреби.

Архітектура мікросервісів різко контрастує з монолітними підходами, такими як тісно пов'язана структура модулів у LangChain. У таких монолітних конструкціях всі модулі взаємозалежні, що створює значні проблеми з розгортанням і обмежує масштабованість. Будь-яка зміна або вимога масштабування в одному модулі вимагає перерозгортання всієї системи, що призводить до потенційних простоїв і збільшення складності.

## Проєктна пропозиція

### Мікросервіс

Мікросервіси подібні до будівельних блоків, пропонуючи фундаментальні послуги для побудови додатків RAG (Retrieval-Augmented Generation). Кожен мікросервіс призначений для виконання певної функції або завдання в архітектурі програми. Розбиваючи систему на менші, автономні сервіси, мікросервіси сприяють модульності, гнучкості та масштабованості. Такий модульний підхід дозволяє розробникам самостійно розробляти, розгортати та масштабувати окремі компоненти програми, що полегшує її підтримку та розвиток з часом. Крім того, мікросервіси полегшують ізоляцію несправностей, оскільки проблеми в одному сервісі з меншою ймовірністю вплинуть на всю систему.

### Мегасервіс

Мегасервіс - це архітектурна конструкція вищого рівня, що складається з одного або декількох мікросервісів і надає можливість збирати наскрізні додатки. На відміну від окремих мікросервісів, які зосереджені на конкретних завданнях або функціях, мегасервіс організовує кілька мікросервісів для надання комплексного рішення. Мегасервіси інкапсулюють складну бізнес-логіку та організацію робочих процесів, координуючи взаємодію між різними мікросервісами для виконання конкретних вимог додатків. Такий підхід дозволяє створювати модульні, але інтегровані додатки, де кожен мікросервіс робить свій внесок у загальну функціональність мегасервісу.

### Шлюз

Шлюз слугує інтерфейсом для доступу користувачів до мегасервісу, забезпечуючи персоналізований доступ на основі вимог користувача. Він діє як точка входу для вхідних запитів, спрямовуючи їх до відповідних мікросервісів в рамках архітектури мегасервісу. Шлюзи підтримують визначення API, версіювання API, обмеження швидкості та трансформацію запитів, що дозволяє тонко контролювати взаємодію користувачів з базовими мікросервісами. Абстрагуючись від складності базової інфраструктури, шлюзи забезпечують безперебійну та зручну взаємодію з мегасервісом.

### Пропозиція
Запропонована архітектура програми ChatQnA передбачає створення двох мегасервісів. Перший мегасервіс функціонує як основний конвеєр, що складається з чотирьох мікросервісів: embedding, retriever, reranking та LLM. Цей мегасервіс розкриває ChatQnAGateway, що дозволяє користувачам запитувати систему через кінцеву точку `/v1/chatqna`. Другий мегасервіс керує зберіганням даних користувача у VectorStore і складається з одного мікросервісу dataprep. Цей мегасервіс надає шлюз DataprepGateway, що дозволяє користувачеві отримати доступ через кінцеву точку `/v1/dataprep`.

Клас Gateway полегшує реєстрацію додаткових кінцевих точок, підвищуючи гнучкість і розширюваність системи. Кінцева точка /v1/dataprep відповідає за обробку користувацьких документів, які зберігатимуться у VectorStore під попередньо визначеним ім'ям бази даних. Потім перший мегасервіс буде запитувати дані з цієї попередньо визначеної бази даних.

![architecture](https://i.imgur.com/YdsXy46.png)


#### Приклад коду Python для побудови сервісів

Користувачі можуть використовувати клас `ServiceOrchestrator` для побудови трубопроводу мікросервісів і додавання шлюзу для кожного мегасервісу.

```python
class ChatQnAService:
    def __init__(self, rag_port=8888, data_port=9999):
        self.rag_port = rag_port
        self.data_port = data_port
        self.rag_service = ServiceOrchestrator()
        self.data_service = ServiceOrchestrator()

    def construct_rag_service(self):
        embedding = MicroService(
            name="embedding",
            host=SERVICE_HOST_IP,
            port=6000,
            endpoint="/v1/embeddings",
            use_remote_service=True,
            service_type=ServiceType.EMBEDDING,
        )
        retriever = MicroService(
            name="retriever",
            host=SERVICE_HOST_IP,
            port=7000,
            endpoint="/v1/retrieval",
            use_remote_service=True,
            service_type=ServiceType.RETRIEVER,
        )
        rerank = MicroService(
            name="rerank",
            host=SERVICE_HOST_IP,
            port=8000,
            endpoint="/v1/reranking",
            use_remote_service=True,
            service_type=ServiceType.RERANK,
        )
        llm = MicroService(
            name="llm",
            host=SERVICE_HOST_IP,
            port=9000,
            endpoint="/v1/chat/completions",
            use_remote_service=True,
            service_type=ServiceType.LLM,
        )
        self.rag_service.add(embedding).add(retriever).add(rerank).add(llm)
        self.rag_service.flow_to(embedding, retriever)
        self.rag_service.flow_to(retriever, rerank)
        self.rag_service.flow_to(rerank, llm)
        self.rag_gateway = ChatQnAGateway(megaservice=self.rag_service, host="0.0.0.0", port=self.rag_port)

    def construct_data_service(self):
        dataprep = MicroService(
            name="dataprep",
            host=SERVICE_HOST_IP,
            port=5000,
            endpoint="/v1/dataprep",
            use_remote_service=True,
            service_type=ServiceType.DATAPREP,
        )
        self.data_service.add(dataprep)
        self.data_gateway = DataPrepGateway(megaservice=self.data_service, host="0.0.0.0", port=self.data_port)

    def start_service(self):
        self.construct_rag_service()
        self.construct_data_service()
        self.rag_gateway.start()
        self.data_gateway.start()

if __name__ == "__main__":
    chatqna = ChatQnAService()
    chatqna.start_service()
```

#### Побудова сервісів за допомогою yaml

Нижче наведено приклад визначення мікросервісів і мегасервісів за допомогою YAML для програми ChatQnA. Ця конфігурація окреслює кінцеві точки для кожного мікросервісу і визначає робочий процес для мегасервісів.

```yaml
opea_micro_services:
  dataprep:
    endpoint: http://localhost:5000/v1/chat/completions
  embedding:
    endpoint: http://localhost:6000/v1/embeddings
  retrieval:
    endpoint: http://localhost:7000/v1/retrieval
  reranking:
    endpoint: http://localhost:8000/v1/reranking
  llm:
    endpoint: http://localhost:9000/v1/chat/completions

opea_mega_service:
  mega_flow:
    - embedding >> retrieval >> reranking >> llm
  dataprep:
    mega_flow:
        - dataprep
```

```yaml
opea_micro_services:
  dataprep:
    endpoint: http://localhost:5000/v1/chat/completions

opea_mega_service:
  mega_flow:
    - dataprep
```

Наступний код на Python демонструє, як використовувати конфігурації YAML для ініціалізації мікросервісів і мегасервісів, а також налаштування шлюзів для взаємодії з користувачами.

```python
from comps import ServiceOrchestratorWithYaml
from comps import ChatQnAGateway, DataPrepGateway
data_service = ServiceOrchestratorWithYaml(yaml_file_path="dataprep.yaml")
rag_service = ServiceOrchestratorWithYaml(yaml_file_path="rag.yaml")
rag_gateway = ChatQnAGateway(data_service, port=8888)
data_gateway = DataPrepGateway(data_service, port=9999)
# Start gateways
rag_gateway.start()
data_gateway.start()
```

#### Приклад коду для налаштування шлюзу

Клас Gateway надає інтерфейс для доступу до мегасервісу, що налаштовується. Він обробляє запити та відповіді, дозволяючи користувачам взаємодіяти з мегасервісом. Клас визначає методи для додавання користувацьких маршрутів, зупинки сервісу та переліку доступних сервісів і параметрів. Користувачі можуть розширити цей клас, щоб реалізувати специфічну обробку запитів і відповідей відповідно до своїх вимог.

```python
class Gateway:
    def __init__(
        self,
        megaservice,
        host="0.0.0.0",
        port=8888,
        endpoint=str(MegaServiceEndpoint.CHAT_QNA),
        input_datatype=ChatCompletionRequest,
        output_datatype=ChatCompletionResponse,
    ):
        ...
        self.gateway = MicroService(
            service_role=ServiceRoleType.MEGASERVICE,
            service_type=ServiceType.GATEWAY,
            ...
        )
        self.define_default_routes()

    def define_default_routes(self):
        self.service.app.router.add_api_route(self.endpoint, self.handle_request, methods=["POST"])
        self.service.app.router.add_api_route(str(MegaServiceEndpoint.LIST_SERVICE), self.list_service, methods=["GET"])
        self.service.app.router.add_api_route(
            str(MegaServiceEndpoint.LIST_PARAMETERS), self.list_parameter, methods=["GET"]
        )

    def add_route(self, endpoint, handler, methods=["POST"]):
        self.service.app.router.add_api_route(endpoint, handler, methods=methods)

    def start(self):
        self.gateway.start()

    def stop(self):
        self.gateway.stop()

    async def handle_request(self, request: Request):
        raise NotImplementedError("Subclasses must implement this method")

    def list_service(self):
        raise NotImplementedError("Subclasses must implement this method")

    def list_parameter(self):
        raise NotImplementedError("Subclasses must implement this method")

    ...
```

## Розглянуті альтернативи
Альтернативним підходом може бути розробка монолітного додатку для RAG замість мікросервісної архітектури. Однак такому підходу може бракувати гнучкості та масштабованості, які пропонують мікросервіси. Переваги запропонованої мікросервісної архітектури включають легше розгортання, незалежне масштабування компонентів та покращену ізоляцію несправностей. До мінусів можна віднести підвищену складність в управлінні декількома сервісами.

## Сумісність
Потенційні несумісні зміни в інтерфейсі або робочому процесі можуть включати коригування, необхідні для взаємодії існуючих клієнтів з новою архітектурою мікросервісів. Однак ретельне планування та комунікація можуть пом'якшити будь-які збої.

## Miscs
Вплив на продуктивність: Архітектура мікросервісів може впливати на показники продуктивності, залежно від таких факторів, як затримка в мережі. Але для широкомасштабного доступу користувачів масштабування мікросервісів може підвищити швидкість реагування, тим самим значно покращуючи продуктивність порівняно з монолітними конструкціями.

Застосовуючи цю мікросервісну архітектуру для RAG, ми прагнемо підвищити гнучкість, масштабованість і ремонтопридатність розгортання корпоративних додатків штучного інтелекту, що в кінцевому підсумку покращить взаємодію з користувачем і полегшить майбутній розвиток і вдосконалення.

