# Поширені запитання з OPEA

## У чому полягає місія OPEA? 
Місія OPEA полягає в тому, щоб запропонувати перевірену еталонну реалізацію RAG GenAI (генеративного штучного інтелекту) корпоративного рівня. Це спростить розробку та розгортання GenAI, тим самим прискорюючи час виходу на ринок.

## Що таке OPEA? 
Наразі проект складається з технічної концептуальної основи, яка дозволяє реалізаціям GenAI відповідати вимогам корпоративного рівня. Проект пропонує набір еталонних реалізацій для широкого спектру корпоративних сценаріїв використання, які можна використовувати «з коробки». Крім того, проект надає набір інструментів перевірки та відповідності, щоб забезпечити відповідність еталонних реалізацій потребам, викладеним у концептуальній структурі. Це дає змогу створювати нові еталонні реалізації та перевіряти їх у відкритий спосіб. Партнерство з LF AI & Data робить його ідеальним місцем для багатостороннього розвитку, еволюції та розширення.

## З якими проблемами стикаються при розгортанні GenAI на підприємстві? 
Підприємства стикаються з безліччю проблем при розробці та розгортанні GenAI. Розробка нових моделей, алгоритмів, методів точного налаштування, виявлення та усунення упередженості, а також способів масштабного розгортання великих рішень продовжує розвиватися швидкими темпами. Однією з найбільших проблем, з якою стикаються підприємства, є відсутність стандартизованих програмних інструментів і технологій, з яких можна було б вибирати. Крім того, підприємствам потрібна гнучкість для швидкого впровадження інновацій, розширення функціональності відповідно до бізнес-потреб, а також безпека та надійність рішення. Відсутність середовища, яке охоплює як пропрієтарні, так і відкриті рішення, заважає підприємствам планувати свою долю. Це призводить до величезних витрат часу та грошей, що впливає на час виходу на ринок. OPEA відповідає на потребу в багатосторонній екосистемній платформі, яка дозволяє оцінювати, обирати, налаштовувати та надійно розгортати рішення, на які може покластися бізнес.

## Чому зараз? 
Основний цикл впровадження та розгортання надійних, безпечних рішень GenAI корпоративного рівня в усіх галузях знаходиться на початковій стадії. Рішення корпоративного рівня вимагатимуть співпраці у відкритій екосистемі. Настав час для екосистеми об'єднатися і прискорити розгортання GenAI на підприємствах, пропонуючи стандартизований набір інструментів і технологій, підтримуючи при цьому три ключові принципи - відкритість, безпеку і масштабованість. Це вимагатиме від екосистеми спільної роботи над створенням еталонних реалізацій, які будуть ефективними, надійними та готовими до використання на рівні підприємств.

## Як це порівняно з іншими варіантами розгортання рішень Gen AI на підприємстві? 
Не існує альтернативи, яка б об'єднувала всю екосистему в нейтральний до постачальників спосіб і забезпечувала відкритість, безпеку і масштабованість. Це наша основна мотивація для створення проекту OPEA.

## Чи працюватимуть еталонні реалізації OPEA з пропрієтарними компонентами? 
Як і будь-який інший проект з відкритим вихідним кодом, спільнота визначатиме, які компоненти потрібні ширшій екосистемі. Підприємства завжди можуть розширити проект OPEA за рахунок інших пропрієтарних рішень від різних постачальників для досягнення своїх бізнес-цілей.

## Що означає абревіатура OPEA?  
Open Platform for Enterprise AI.

## Як вимовляється слово OPEA?? 
Це вимовляється як ‘OH-PEA-AY.’

## What initial companies and open-source projects joined OPEA?
AnyScale, Cloudera, DataStax, Domino Data Lab, HuggingFace, Intel, KX, MariaDB Foundation, MinIO, Qdrant, Red Hat, SAS, VMware by Broadcom, Yellowbrick Data, Zilliz.

## Який внесок робить Intel? 
OPEA буде визначено спільно кількома партнерами спільноти, із закликом до широкої участі в екосистемі, в рамках добре створеного Фонду LF AI & Data Foundation. Для початку Intel надала Технічну концептуальну основу, яка показує, як будувати та оптимізувати кураторські  трубопроводи GenAI, створені для безпечного розгортання «під ключ» на підприємствах. На початку Intel надала кілька еталонних реалізацій на апаратному забезпеченні Intel на базі Intel® Xeon® 5, Intel® Xeon® 6 та Intel® Gaudi® 2, які можна переглянути в репозиторії GitHub за цим посиланням. Згодом ми плануємо доповнити цей внесок, включно зі стеком програмної інфраструктури, щоб уможливити розгортання повністю контейнерних робочих навантажень ШІ, а також потенційні реалізації цих контейнерних робочих навантажень.

## Коли ви говорите про Технічну концептуальну основу, які компоненти входять до неї??
Моделі та модулі можуть бути частиною репозиторію OPEA або публікуватися в стабільному, безперешкодному репозиторії (наприклад, Hugging Face) і бути допущеними до використання за результатами оцінки OPEA. До них відносяться:

* Ingest/Data Processing 
* Embedding Models/Services 
* Indexing/Vector/Graph data stores 
* Retrieval/Ranking 
* Prompt Engines 
* Guardrails 
* Memory systems 

## Яким чином партнери можуть зробити свій внесок в ОPЕА? 
Партнери можуть зробити свій внесок у цей проект різними способами: 

* Приєднатися до проекту та надати ресурси у вигляді кейсів використання, коду, тестових харнесів тощо. 
* Забезпечити технічне керівництво  
* Сприяти залученню спільноти та поширенню 
* Запропонувати управління програмами для різних проектів 
* Стати розробником, компілятором і користувачем 
* Визначити і запропонувати варіанти використання для різних галузевих вертикалей, які формують проект OPEA 
* Розбудовувати інфраструктуру для підтримки проектів OPEA 

## Де партнери можуть ознайомитися з останнім проектом специфікації Концептуальних засад? 
Версія специфікації доступна у репозиторії документації (["docs"](https://github.com/opea-project/docs)) цього проекту. 

## Чи потрібно платити за приєднання?? 
Приєднання до проекту OPEA є безкоштовним для всіх, хто бажає зробити свій внесок. 

## Чи потрібно бути членом Linux Foundation, щоб приєднатися??
Будь-хто може приєднатися і зробити свій внесок. Вам не потрібно бути членом Linux Foundation. 

## Куди я можу повідомити про баг або вразливість?
Звіти про уразливості та повідомлення про помилки можна надсилати на адресу [info@opea.dev](mailto:info@opea.dev).