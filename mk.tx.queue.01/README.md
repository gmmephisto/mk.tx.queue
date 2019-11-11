## mk.tx.queue.task01

* Queue space definition and initial index
* Simple put method
* Docker compose with tty

```sh
$ docker-compose up -d
Creating network "mktxqueue01_default" with the default driver
Creating mktxqueue01_queue_1 ... done
```
```sh
docker-compose exec queue console
connected to unix/:/var/run/tarantool/tarantool.sock
unix/:/var/run/tarantool/tarantool.sock> 
```
```sh
unix/:/var/run/tarantool/tarantool.sock> queue.put("one")
---
- [1573512634077325, 'R', 'one']
...

unix/:/var/run/tarantool/tarantool.sock> queue.put("two")
---
- [1573512636926164, 'R', 'two']
...

unix/:/var/run/tarantool/tarantool.sock> queue.put("three", 3)
---
- [1573512645138703, 'R', 'three', 3]
...

unix/:/var/run/tarantool/tarantool.sock> queue.put({one = {two = 2}})
---
- [1573512669328604, 'R', {'one': {'two': 2}}]
...

unix/:/var/run/tarantool/tarantool.sock> box.space.queue:select()
---
- - [1573512634077325, 'R', 'one']
  - [1573512636926164, 'R', 'two']
  - [1573512645138703, 'R', 'three', 3]
  - [1573512669328604, 'R', {'one': {'two': 2}}]
...

```
