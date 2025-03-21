.. _GenAIExamples:

GenAI Examples
##############

GenAIExamples призначені для того, щоб полегшити розробникам початок роботи з генеративним ШІ, і містять приклади на основі мікросервісів, які спрощують процеси розгортання, тестування та масштабування додатків GenAI. Усі приклади повністю сумісні з Docker і Kubernetes, підтримують широкий спектр апаратних платформ, таких як Gaudi, Xeon і NVIDIA GPU, а також інше обладнання, забезпечуючи гнучкість і ефективність вашого впровадження GenAI.


.. toctree::
   :maxdepth: 1

   ChatQnA/ChatQnA_Guide

----

Ми створюємо цю документацію на основі вмісту в
:GenAIExamples_blob:`GenAIExamples<README.md>` репозиторію GitHub.

.. rst-class:: rst-columns

.. toctree::
   :maxdepth: 1
   :glob:

   /GenAIExamples/README
   /GenAIExamples/*

**Example Applications Table of Contents**

.. rst-class:: rst-columns

.. contents::
   :local:
   :depth: 1

----

.. comment Цей include-файл генерується у Makefile під час збирання документа з усіх каталогів, знайдених у каталозі верхнього рівня GenAIExamples

.. include:: examples.txt
