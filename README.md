# xmake-stm32plg
Create a project of stm32 by xmake plugin.

It just be used to generate stm32f103zetx project.

## generated project directory

```
|-- core
|-- include
    |-- stm32f10x_conf.h
    |-- stm32f10x_it.h
    |-- stm32f10x.h
    |-- system_stm32f10x.h
|-- lib
    |-- include
    |-- src
|-- src
    |-- main.c
    |-- stm32f10x_it.c
    |-- system_stm32f10x.c
|-- startup_*.s
|-- stm32.ld
|-- xmake.lua
```