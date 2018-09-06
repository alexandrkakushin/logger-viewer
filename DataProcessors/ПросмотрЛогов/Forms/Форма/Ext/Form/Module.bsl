﻿
///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// todo: в отдельные настройки пользователя
	ГруппироватьСообщения = Истина;
	
	НачалоПериода = НачалоДня(ТекущаяДатаСеанса());
	КонецПериода = КонецДня(ТекущаяДатаСеанса()) + 1;
	
	УправлениеФормой(ЭтаФорма);
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ КОМАНД ФОРМЫ

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Получить(Команда)
	
	Если ЗначениеЗаполнено(Компонента) И ЗначениеЗаполнено(Лог) Тогда
		ПолучитьСообщения();
	Иначе
		ПоказатьПредупреждение(, НСтр("ru = 'Для получения сообщений необходимо выбрать Компоненту и Лог'"));		
	КонецЕсли;	
		
КонецПроцедуры

&НаКлиенте
Процедура УдалитьВсеСообщения(Команда)
	
	Если ЗначениеЗаполнено(Компонента) И ЗначениеЗаполнено(Лог) Тогда
		ПоказатьВопрос(
			Новый ОписаниеОповещения("УдалитьВсеСообщенияПослеВыбора", ЭтаФорма), 
			НСтр("ru = 'Удалить все сообщения из выбранного лога?'"), 
			РежимДиалогаВопрос.ДаНет);
	Иначе
		ПоказатьПредупреждение(, НСтр("ru = 'Для удаления сообщений необходимо выбрать Компоненту и Лог'"));		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ФОРМЫ

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура КомпонентаПриИзменении(Элемент)
	
	Элементы.Лог.СписокВыбора.ЗагрузитьЗначения(
		КомпонентыВызовСервера.ЛогиКомпоненты(Компонента));
	
КонецПроцедуры

&НаКлиенте
Процедура ГруппироватьПриИзменении(Элемент)
	
	УправлениеФормой(ЭтаФорма);	
	
	СформироватьПредставление();
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС

#Область ПрограммныйИнтерфейс

&НаКлиенте
Процедура УдалитьВсеСообщенияПослеВыбора(Результат, ДополнительныеПараметры) Экспорт
	
	ОписаниеОшибки = Неопределено;
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		РезультатУдаления = КомпонентыВызовСервера.УдалитьВсеСообщения(Компонента, Лог, ОписаниеОшибки);	
		
		Если РезультатУдаления Тогда
			ПоказатьПредупреждение(, НСтр("ru = 'Сообщения удалены'"));
		Иначе
			Если ЗначениеЗаполнено(ОписаниеОшибки) Тогда
				ПоказатьПредупреждение(, ОписаниеОшибки);
			Иначе
				ПоказатьПредупреждение(, НСтр("ru = 'В процессе удаления сообщений произошла ошибка'"));
			КонецЕсли;
		КонецЕсли;		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Процедура УправлениеФормой(ЭтаФорма)
	
	Элементы = ЭтаФорма.Элементы;
	
	Элементы.СообщенияОтображениеКоличество.Видимость = ЭтаФорма.ГруппироватьСообщения;
	Элементы.СообщенияОтображениеПериод.Видимость = Не ЭтаФорма.ГруппироватьСообщения;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ФайлыЛогов(Компонента)
	

	
КонецФункции

&НаСервере
Процедура ПолучитьСообщения()
	
	Сообщения.Очистить();	
	СообщенияЛога = Компоненты.Сообщения(Компонента, Лог, НачалоПериода, КонецПериода);	
	Для Каждого ЭлементКоллекции Из СообщенияЛога Цикл
		НоваяСтрока = Сообщения.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, ЭлементКоллекции);
		НоваяСтрока.Количество = 1;		
	КонецЦикла;
	
	СформироватьПредставление();
		
КонецПроцедуры

&НаСервере
Процедура СформироватьПредставление()
	
	СообщенияОтображение.Очистить();
	
		// Представление
	Если ГруппироватьСообщения Тогда
		Свертываемая = Новый ТаблицаЗначений();
		Свертываемая.Колонки.Добавить("Объект", Новый ОписаниеТипов("Строка"));
		Свертываемая.Колонки.Добавить("Уровень", Новый ОписаниеТипов("Строка"));
		Свертываемая.Колонки.Добавить("Текст", Новый ОписаниеТипов("Строка"));
		Свертываемая.Колонки.Добавить("Количество", Новый ОписаниеТипов("Число"));
		Для Каждого ЭлементКоллекции Из Сообщения Цикл
			ЗаполнитьЗначенияСвойств(Свертываемая.Добавить(), ЭлементКоллекции);
		КонецЦикла;		
		Свертываемая.Свернуть("Объект, Уровень, Текст", "Количество");
		
		Для Каждого ЭлементКоллекции Из Свертываемая Цикл
			ЗаполнитьЗначенияСвойств(СообщенияОтображение.Добавить(), ЭлементКоллекции);
		КонецЦикла;
	Иначе		
		Для Каждого ЭлементКоллекции Из Сообщения Цикл
			ЗаполнитьЗначенияСвойств(СообщенияОтображение.Добавить(), ЭлементКоллекции);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти