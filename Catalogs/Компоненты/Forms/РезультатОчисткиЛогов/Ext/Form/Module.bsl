﻿
///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПараметрКомпонента = Неопределено;
	Если Параметры.Свойство("Компонента", ПараметрКомпонента) Тогда
		Если Не ТипЗнч(ПараметрКомпонента) = Тип("СправочникСсылка.Компоненты") Тогда			
			ВызватьИсключение НСтр("ru = 'Отсутствует компонента для отображения результатов'");
		КонецЕсли;
	КонецЕсли;
	
	ПараметрРезультат = Неопределено;
	Если Параметры.Свойство("Результат", ПараметрРезультат) Тогда
		Если Не ТипЗнч(ПараметрРезультат) = Тип("Массив") Тогда
			ВызватьИсключение НСтр("ru = 'Отсутствуют данные для отображения результатов'");
		КонецЕсли;
	КонецЕсли;
	
	Компонента = ПараметрКомпонента;
	Для Каждого СтрокаТЧ Из ПараметрРезультат Цикл
		ЗаполнитьЗначенияСвойств(Логи.Добавить(), СтрокаТЧ);
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти