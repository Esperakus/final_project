# Курсовой проект "Создание высокодоступной инфраструктуры для Golang web-приложения в облаке Yandex.Cloud"

Схема проекта:


![scheme](https://github.com/Esperakus/final_project/blob/main/pics/project.png)

Проект состоит из следующих частей:
- кластер приложения
- кластер баз данных
- мониторинг
- балансировщик запросов с резервированием

Вся инфраструктура проекта создаётся автоматически с помощью манифестов terraform и плейбуков ansible.
На всех нодах проекта настроен firewalld с политикой "Запрещать все входящие соединения, кроме явно разрешённых". В качестве ssh jump-host используется нода, с которой запускается разворачивания ansible-playbook, доступ на неё только по ключу ssh.

## Кластер приложения
Веб-приложение работает на трёх нодах - backend01, backend02, backend03. Балансировка запросов происходит с помощью двух HAProxy balancer01 и balancer02, запросы на которые в свою очередь идут через внешний балансировщик Yandex.Cloud. В качестве внешнего балансировщика в реальных продуктовых условиях можно использовать например внешний сервис с защитой от DDoS и Web Application Firewall. 

Высокая доступность приложения достигается за счёт работы балансировщиков HAProxy, рапределяющих запросы равномерно между бэкендами (roundrobin). В случае отказа одной из нод с приложением она исключается из балансировки на HAProxy, запросы продолжают распределяться между оставшимися нодами. Отказ в обслуживании части запросов возможен на период принятия балансировщиком решения об исключении ноды из балансировки (две проверки с периодом в 1 секунду, если обе неудачные - нода считается упавшей). При восстановлении ноды балансировщики вновь распределяют трафик с учётом вернувшейся в работу ноды.

Поскольку предполагается, что на нодах с приложением должны присутствовать файлы статики, например файлы конфигурации приложения, то на нодах настроена распределённая кластерная система GlusterFS в режиме репликации для хранения таких файлов.

Работоспособность кластера приложений остаётся при отказе одной из трёх нод.
Пример вывода работы приложения:

![scheme](https://github.com/Esperakus/final_project/blob/main/pics/pic01.png)

![scheme](https://github.com/Esperakus/final_project/blob/main/pics/pic02.png)

## Кластер баз данных
Веб-приложение использует для работы БД PostgresQL. Для обеспечение высокой доступности БД настроен кластер Patroni из трёх нод, который позволяет управлять репликацией данных между нодами и динамически переключать роль main на другую ноду в случае отказа. Подключение к кластеру осуществляется через внутренний балансировщик Yandex.Cloud, который балансирует запросы на HAProxy balancer01 и balancer02. Такая схема подключения выбрана по причине отсутствия поддержки протокола VRRP в сетях Yandex.Cloud. Балансировщик HAProxy определяет основную ноду кластера БД и направляет запросы от приложения на неё. В случае, если применяется балансировка запросов в БД на уровне самого приложения - когда приложение само может определить основную ноду кластера БД, чтоб направлять запросы на запись в неё, а на чтение на все ноды - то необходимости балансировать запросы к БД через HAProxy нет.

Работоспособность кластера БД остаётся при отказе одной из трёх нод.

Пример вывода запроса в БД:


![scheme](https://github.com/Esperakus/final_project/blob/main/pics/pic03.png)


## Мониторинг
Мониторинг в проекте реализован на основе VictoriaMetrics и Grafana. На всех виртуальных машинах запущен сервис node_exporter, к которому периодически приходят запросы метрик со стороны VictoriaMetrics. Полученные метрики могут быть визуализированы в Grafana, также можно настроить alerts например в telegram с помощью Grafana Alert Manager. Тогда при выходе значений полученных метрик за пределы значений определённых как критические, служба поддержки проекта будет получать оповещение.

Пример работы мониторинга:
![scheme](https://github.com/Esperakus/final_project/blob/main/pics/mon.png)
