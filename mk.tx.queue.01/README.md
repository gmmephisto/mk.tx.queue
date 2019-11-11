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

* Status index and take method

```sh
unix/:/var/run/tarantool/tarantool.sock> queue.put(1)
---
- [1573513206474576, 'R', 1]
...

unix/:/var/run/tarantool/tarantool.sock> queue.put(2)
---
- [1573513208176796, 'R', 2]
...

unix/:/var/run/tarantool/tarantool.sock> queue.put(3)
---
- [1573513209626059, 'R', 3]
...

unix/:/var/run/tarantool/tarantool.sock> queue.take()
---
- [1573513206474576, 'T', 1]
...

unix/:/var/run/tarantool/tarantool.sock> queue.take()
---
- [1573513208176796, 'T', 2]
...

unix/:/var/run/tarantool/tarantool.sock> box.space.queue:select()
---
- - [1573513206474576, 'T', 1]
  - [1573513208176796, 'T', 2]
  - [1573513209626059, 'R', 3]
...

unix/:/var/run/tarantool/tarantool.sock> queue.take()
---
- [1573513209626059, 'T', 3]
...

unix/:/var/run/tarantool/tarantool.sock> queue.take()
---
...

unix/:/var/run/tarantool/tarantool.sock> 
```

* Ack and release taken tasks

```sh
unix/:/var/run/tarantool/tarantool.sock> queue.put("one")
---
- [1573515524226896, 'R', 'one']
...

unix/:/var/run/tarantool/tarantool.sock> queue.put("two")
---
- [1573515530802276, 'R', 'two']
...

unix/:/var/run/tarantool/tarantool.sock> box.space.queue:select()
---
- - [1573515524226896, 'R', 'one']
  - [1573515530802276, 'R', 'two']
...

unix/:/var/run/tarantool/tarantool.sock> t = queue.take()
---
...

unix/:/var/run/tarantool/tarantool.sock> t.id
---
- 1573515524226896
...

unix/:/var/run/tarantool/tarantool.sock> queue.ack(t.id)
---
- [1573515524226896, 'T', 'one']
...

unix/:/var/run/tarantool/tarantool.sock> box.space.queue:select()
---
- - [1573515530802276, 'R', 'two']
...
```
