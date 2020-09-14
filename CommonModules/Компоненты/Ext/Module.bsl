﻿
///////////////////////////////////////////////////////////////////////////////
// API (Info)

#Область API_Info

Функция ПроксиКомпоненты(Компонента, ПопыткаПодключения = 1) Экспорт
	
	АдресWSDL =                                            
		"http://" + Компонента.Хост + ":" + Формат(Компонента.Порт, "ЧГ=0") + "/Info?wsdl";		
	Определение = Новый WSОпределения(АдресWSDL);	
	Прокси = Новый WSПрокси(Определение, "http://info.ak.ru/", "Info", "InfoPort");
			
	Возврат Прокси;
	
КонецФункции

Функция КомпонентаДоступна(Компонента) Экспорт
			
	Возврат ПроксиКомпоненты(Компонента) <> Неопределено;
	
КонецФункции

Функция ВерсияКомпоненты(Компонента) Экспорт
	
	Версия = Неопределено;
	
	Попытка
		Прокси = ПроксиКомпоненты(Компонента);
		Если Прокси <> Неопределено Тогда		
			Версия = Прокси.version();	
		КонецЕсли;
	Исключение
		
	КонецПопытки;
		Версия = НСтр("ru = 'API компоненты не доступно.'");;	
	Возврат Версия;
		
КонецФункции

// Прикладное

Функция ЛогиКомпоненты(Компонента) Экспорт
	
	Результат = Новый Массив();
	
	Попытка
		Прокси = ПроксиКомпоненты(Компонента);
		Если Прокси <> Неопределено Тогда
			// todo: метод без параметров, но 1С упорно его видит
			Параметры = Прокси.ФабрикаXDTO.Создать("http://info.ak.ru/", "logs");
			ЛогиXDTO =  Прокси.logs(Параметры);
			Для Каждого ЛогXDTO Из ЛогиXDTO.return Цикл
				Результат.Добавить(ЛогXDTO);
			КонецЦикла;
		КонецЕсли;
	Исключение
		Сообщить(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));		
	КонецПопытки;
		
	Возврат Результат;
		
КонецФункции

Функция Сообщения(Компонента, Лог, НачалоПериода, КонецПериода, Лимит = 100, Смещение = 0) Экспорт
	
	Результат = Новый Структура("Сообщения, Количество", Новый Массив(), 0);
	
	Если Не ЗначениеЗаполнено(Лог) Тогда
		Сообщить(НСтр("ru = 'Не заполнено имя файла лога'"));
		Возврат Результат;		
	КонецЕсли;
	
	Попытка			
		Соединение = Новый HTTPСоединение(Компонента.Хост, Компонента.Порт);
			
		ТекстЗапроса = СтрШаблон(
			"<soapenv:Envelope xmlns:soapenv=""http://schemas.xmlsoap.org/soap/envelope/"" xmlns:info=""http://info.ak.ru/"" xmlns:con=""http://connection.logger.ak.ru/"">
			|   <soapenv:Header/>
			|   <soapenv:Body>
			|      <info:messagesByPeriod>
			|         <connection>
			|            <con:fileName>%1</con:fileName>
			|         </connection>         
			|         <from>%2</from>
			|         <to>%3</to>
			|         <limit>%4</limit>
			|         <offset>%5</offset>
			|      </info:messagesByPeriod>
			|   </soapenv:Body>
			|</soapenv:Envelope>",
				Лог, 
				Формат(НачалоПериода, "ДФ=yyyy-MM-dd"), 
				Формат(КонецПериода, "ДФ=yyyy-MM-dd"),
				Формат(Лимит, "ЧГ=0"),
				Формат(Смещение, "ЧН=0; ЧГ=0"));
								
		Заголовки = Новый Соответствие;

		Заголовки.Вставить("Content-Type", "text/xml;charset=UTF-8");
		
		Запрос = Новый HTTPЗапрос("/Info/messagesByPeriod", Заголовки);
		Запрос.УстановитьТелоИзСтроки(ТекстЗапроса);
		
		ОтветСервера = Соединение.ОтправитьДляОбработки(Запрос);
		Если ОтветСервера.КодСостояния = 200 Тогда
			ТелоОтвета = ОтветСервера.ПолучитьТелоКакСтроку();
			
		    ЧтениеXML = Новый ЧтениеXML();
		    ЧтениеXML.ОткрытьПоток(ОтветСервера.ПолучитьТелоКакПоток());
		    Фабрика = Новый ФабрикаXDTO();
		    ТелоXDTO = Фабрика.ПрочитатьXML(ЧтениеXML);
			
			РезультатXDTO = ТелоXDTO.Body.messagesByPeriodResponse.return;
			Если Число(РезультатXDTO.count) > 0 Тогда
				Для Каждого СообщениеXDTO Из РезультатXDTO.message Цикл
					Запись = Новый Структура("Период, Объект, Уровень, Текст");
					
					ПериодСтрокой = Лев(СообщениеXDTO.period, 19);
					ПериодСтрокой = СтрЗаменить(ПериодСтрокой, "-", "");
					ПериодСтрокой = СтрЗаменить(ПериодСтрокой, ":", "");
					ПериодСтрокой = СтрЗаменить(ПериодСтрокой, "T", "");
									
					Запись.Период  = Дата(ПериодСтрокой);;
					Запись.Объект  = СообщениеXDTO.objectLog.name;
					Запись.Уровень = СообщениеXDTO.level.name;
					Запись.Текст   = СообщениеXDTO.text;
					
					Результат.Сообщения.Добавить(Запись);
				КонецЦикла;	
				
				Результат.Количество = Число(РезультатXDTO.count);
			КонецЕсли;			
		Иначе
			ВызватьИсключение 
				СтрШаблон(НСтр("ru = 'Код ответа: %1, Тело: %2'"), 
			    	ОтветСервера.КодСостояния,
					ОтветСервера.ПолучитьТелоКакСтроку());
		КонецЕсли;	
	Исключение
		Сообщить(НСтр("ru = 'Не удалось загрузить сообщения компоненты'"));
	КонецПопытки;
	
	Возврат Результат;
	
КонецФункции

Функция ОчиститьВсеСообщения(Компонента, Лог) Экспорт
	
	Результат = Ложь;
	
	Прокси = ПроксиКомпоненты(Компонента);
	Если Прокси <> Неопределено Тогда
		connection = XDTOConnection(Прокси);
		connection.fileName = Лог;		
				
		РезультатXDTO = Прокси.clearMessages(connection);
		Результат = Не РезультатXDTO.error;		
	КонецЕсли;
	
	Возврат Результат;
		
КонецФункции

#КонецОбласти


///////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

#Область СлужебныеПроцедурыИФункции

Функция XDTOConnection(Прокси)
	
	connection = Неопределено;
	
	Попытка
		connection = Прокси.ФабрикаXDTO.Создать("http://connection.logger.ak.ru/", "sqliteConnection");
	Исключение
		// Для совместимости с первыми версиями компоненты
		connection = Прокси.ФабрикаXDTO.Создать("http://info.ak.ru/", "sqliteConnection");
	КонецПопытки;
	
	Возврат connection;
	
КонецФункции

#КонецОбласти