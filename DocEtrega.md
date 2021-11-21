# Documento de entrega

Este documento corresponde a la guia paso a paso para poder crear pruebas de carga y pruebas de stress a servicios en paginas web. Estas pruebas se usan para validar tiempos de respuesta, tiempos de envio y respuestas exitosas o negatas con cargas predeterminadas, siendo evaluadas por azure Insight para poder crear acciones de alerta.

# Introducción
Esta solución se desarrollo bajo varias herramientas:

- Jmeter
- Azure Insight
- Azure Funtion App

Jmeter es una aplicación de codigo abierto, la cual permite al usuario crear y ejecutar test scripts para validar el rendimiento de una aplicacion. El rendimiento es extraido realizando multiples acciones en la aplicacion de manera continuada con un determinado número de usuarios (threads). Al finalizar la ejecución proporciona al usuario informes sobre el rendimiento. Mediante un plugin [Azure Backend Listener](https://github.com/adrianmo/jmeter-backend-azure) envia las metricas a una instancia en Azure Application Insights.

# Paso a paso

## 1. Crear una instancia de Application Insights:

El primer paso es crear una instancia de [App Insight](https://docs.microsoft.com/es-es/azure/azure-monitor/app/app-insights-overview). Despues de creado asegurese tomar la clave de instrumentacion, que se debera usar por el listener para enviar las metricas.

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_1.png)


## 2. Instalar Java:
JMeter es una aplicacion Java, por tanto, debe estar seguro que en la maquina donde se alojara este agente debe tener instalado una version de java. Puede comprobar si la version de java esta instalada en su sistema abriendo un CMD y escribiendo <em>java -version</em>. 

``C:\> Java -version
Java version "1.8.0_241"
Java(TM) SE Runtime Environment (build 1.8.0_241-b07)
Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)``

Se debe tener un resultado como el anterior, ya que java si no esta presente no podra instalar el Jmeter, de lo contrario, recibira un mensaje como "java no reconoce". [Click para descargar el Java](https://www.java.com/es/download/ie_manual.jsp)

## 3. Instalar JMeter
Ya instala el java, puede descargar los archivos binarios de [Apache Jmeter ](https://jmeter.apache.org/download_jmeter.cgi) mas recientes del sitio oficial y descomprimirlos en una ubicacion que se desee. Despues de descargado, descomprima y navegue hasta el directorio de JMeter, asegúrese de que JMeter pueda iniciarse. Para ejecutar JMeter, busque el directorio <em>bin/ </em> y ejecute jmeter.bat (si está en Windows) o jmeter.sh (si está en Linux).  [Click aqui para descargar el plugin Azure Backend Listener](https://github.com/adrianmo/jmeter-backend-azure)


![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_2.png)

## 4. Instale el plugin
Vaya a las versiones de GitHub para el agente de escucha de backend de Azure y descargue el archivo JAR para obtener la última versión. El archivo JAR requerido tiene el formato jmeter.backendlistener.azure-XYZjar .

Mueva el archivo JAR al directorio JMeter dentro de los directorios lib / ext / . Su directorio ext debería verse así:

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_3.png)

## 5. Configure el complemento
Para hacer que JMeter envíe métricas de resultados de prueba a su instancia de Azure Application Insights, en su Plan de prueba, haga clic con el botón derecho en <em>Test Group > Thread Group > Add > Listener> Backend listener y elija io.github.adrianmo.jmeter.backendlistener.azure.AzureBackendClient </em> desde la lista desplegable de implementación del listener.

Luego, en la tabla Parámetros, configure los siguientes atributos.
| Atributo           | Descripción | Obligatorio |   |   |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|---|---|
| instrumentationKey | La clave de instrumentación de su instancia de Application Insights                                                                                        | Si          |   |   |
| testName           | Nombre de la prueba. Este valor se utiliza para diferenciar métricas entre ejecuciones de prueba o planes en Application Insights y le permite filtrarlas. | Si          |   |   |
| liveMetrics        | Booleano para indicar si las métricas en tiempo real están habilitadas y disponibles en Live Metrics Stream . Por defecto es verdadero .                   | Si          |   |   |
 
Ejemplo de configuración:
---
![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_4.png)

## 6. Creación de la prueba
Para este proceso se debe considerar el proceso y/o ruta para el servicio que se desea evaluar, en este caso en particular, se pretende evaluar el rendimiento del servicio de saldo de factura.

### 6.1. Ruta del proceso

- Iniciar la pagina principal de EPM
- Ir a transaciones rapidas
- Ir a saldo de Factura
- Digitar el numero del contrato del o los servicios que les presta EPM
- Descargar PDF

### 6.2. Grabador de secuencias de comandos de prueba de Apache JMeter HTTP (S)

Jmeter utiliza un metodo para registrar solicitudes HTTP, ese se llama TestRecording, este proceso lo usa para guardar las solitudes que pasan en un proxy configurado anteriormente.

### 6.2.1. configurar el browser para usar el jmeter proxy
En este punto, el proxy de JMeter se debe estar ejecutando. Para este ejercicio, usaremos Firefox para ver las páginas en el sitio web de JMeter.

- Inicie Firefox, pero no cierre JMeter.
- Desde la barra de herramientas, haga clic en Editar  →  Preferencias (o Herramientas  →  Preferencias o escriba acerca de: preferencias # avanzadas como URL). Esto debería mostrar las opciones.

- Seleccione la pestaña Avanzado y la pestaña Red
- Haga clic en el botón Configuración cerca de la parte superior.
- En la nueva ventana emergente, marque Configuración manual del proxy . Los campos de dirección y puerto deberían estar habilitados ahora.
- En dirección ingrese localhost o la dirección IP de su sistema
- Puerto ingrese 8888 .

- Marque Usar este servidor proxy para todos los protocolos
- Haga clic en el botón Aceptar . Esto debería regresar al navegador.

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_5.png)


En este punto el proxy del jmeter ya esta funciono, adicionalmente, se debe agregar un certificado de seguridad. 

1. Privacidad y seguridad → Ver certificado → Importar

2. Dirigirse al directorio donde se encuentra el JMeter e ir a la dirección <em>..\apache-jmeter-5.4.1\apache-jmeter-5.4.1\bin</em>

3. Agregar el certificado <em>ApacheJMeterTemporaryRootCA.crt </em>


![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_6.png)

Este procedimiento se realiza con el fin de evitar el error de Strict Transport Security (HSTS)

![Example](https://github.com/gachavesb/terraform_devops/blob/main/image.png)

### 6.2.2. Agregue el HTTP(S) Test Script Recorder

1.  Se debe generar un nuevo Test Plan
2.  En test plan, hacer click derecho.
3.  Add → Non-Test Element → HTTP(S) Test Script Recorder
4.  En Global Settings se debe configurar lo siguiente
    
    - Port: 8888
    - HTTPS Domains: (la pagina a evaluar) En este caso es www.epm.com.co
 
5. Inicie la grabacion haciendo click en el boton de start

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_7.png)

### 6.2.3. Grabe su navegación
1. En el navegador, enrute su navegacion como se menciona los pasos 6.1. 
2. Haga clic en los enlaces de las paginas mencionadas
3. Cierre su navegador y abra la ventana del jmeter
4. En Thread Group, extienda el menu y deberia haber varias muestras.

### 6.3. Inicie Pruebas
1. En Thread Group debe configurar la carga que desea darle al servicio. Escoja una cantidad de usuarios <em> Number of Threads </em>, el tiempo de prueba  <em> Ramp-up period (seconds) </em> y la cantidad de ciclos que desea repetir la prueba <em> Loop count </em>
2. Iniciar la prueba
3. Esto tomara un tiempo dependiento de la maquina donde se corra y el tiempo como cantidad de usuarios que definio en la configuracion.

## 7. Verificacion de envio de datos
Después de aproximadamente un minuto, la prueba finaliza y puede verificar si sus métricas están disponibles en Application Insights. En Azure Portal, vaya a su instancia de Application Insights y vaya a <em> Monitoring > Logs </em>. Haga doble clic en la <em>requests</em>  para explorar las métricas enviadas por JMeter. Si no ve las métricas, espere unos minutos más hasta que aparezcan. Asegúrese de verificar también las métricas adicionales disponibles dentro de <em>customDimensions</em> .

En este caso, realizamos un query para validar las respuestas correctas e incorrectas que nos envia despues del test

``requests | where name == 'jmeter' | summarize Count=count() by success; ``

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_8.png)

También puede crear gráficos personalizados para visualizar sus métricas. 

``requests | where name == "jmeter" | summarize Count=count() by success | render columnchart``

Además, si habilitó liveMetrics en la configuración, puede ver el rendimiento de su prueba en tiempo real en <em>Live Metrics Stream</em>.

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_9.png)

## 8. Creacion de acciones de alerta
Un grupo de acciones es una colección de preferencias de notificación definidas por el propietario de una suscripción de Azure. Las alertas de Azure Monitor, Service Health, Azure Advisor y Azure Application Insight usan grupos de acción para notificar a los usuarios que se ha activado una alerta. Varias alertas pueden usar el mismo grupo de acción o diferentes grupos de acción según los requisitos del usuario.

### 8.1. Crear un grupo de acciones mediante el portal de Azure
En Azure Portal , busque y seleccione Monitor . El panel Monitor consolida todos los datos y la configuración de supervisión en una sola vista.

1. Seleccione Alertas , luego seleccione grupo de acciones.

2. Botón grupo de  acciones

3. Seleccione Agregar grupo de acciones y complete los campos relevantes en la experiencia del asistente.


![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_11.png)

### Configurar los ajustes básicos del grupo de acciones

1. Seleccione la suscripción y el grupo de recursos en el que se guarda el grupo de acciones.

2. Ingrese un nombre de grupo de acción

3. Ingrese un nombre para mostrar . El nombre para mostrar se usa en lugar del nombre completo del grupo de acciones cuando se envían notificaciones mediante este grupo.

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_12.png)

### Configurar notificaciones
1. Haga clic en el botón Siguiente: Notificaciones> para ir a la pestaña Notificaciones , o seleccione la pestaña Notificaciones en la parte superior de la pantalla.

2. Defina una lista de notificaciones para enviar cuando se active una alerta. Proporcione lo siguiente para cada notificación:

    - Tipo de notificación : seleccione el tipo de notificación que desea enviar. Las opciones disponibles son:

      - Envíe un correo electrónico a Azure Resource Manager Role: envíe un correo electrónico a los usuarios asignados a determinados roles ARM de nivel de suscripción.
      - Correo electrónico / SMS / Push / Voice: envíe estos tipos de notificación a destinatarios específicos.
  
3. Nombre : ingrese un nombre único para la notificación.

4. Detalles : según el tipo de notificación seleccionado, ingrese una dirección de correo electrónico, número de teléfono, etc.

5. Esquema de alerta común : puede optar por habilitar el esquema de alerta común , que ofrece la ventaja de tener una única carga útil de alerta unificada y extensible en todos los servicios de alerta en Azure Monitor.

---

### Configurar acciones
1. Haga clic en el botón Siguiente: Acciones> para ir a la pestaña Acciones , o seleccione la pestaña Acciones en la parte superior de la pantalla.

2. Defina una lista de acciones que se activarán cuando se active una alerta. Proporcione lo siguiente para cada acción:

   - Tipo de acción : seleccione Runbook de automatización, Función de Azure, ITSM, Aplicación lógica, Webhook seguro, Webhook.

   - Nombre : ingrese un nombre único para la acción.

   - Detalles : según el tipo de acción, ingrese un URI de webhook, una aplicación de Azure, una conexión ITSM o un runbook de automatización. Para Acción ITSM, especifique adicionalmente Elemento de trabajo y otros campos que requiera su herramienta ITSM.

   - Esquema de alerta común : puede optar por habilitar el esquema de alerta común , que ofrece la ventaja de tener una única carga útil de alerta unificada y extensible en todos los servicios de alerta en Azure Monitor.

![Example](https://github.com/gachavesb/terraform_devops/blob/main/Screenshot_13.png)

### Crea el grupo de acción
1. Puede explorar la configuración de Etiquetas si lo desea. Esto le permite asociar pares clave / valor al grupo de acciones para su categorización y es una característica disponible para cualquier recurso de Azure.

2. Haga clic en Revisar + crear para revisar la configuración. Esto hará una validación rápida de sus entradas para asegurarse de que todos los campos obligatorios estén seleccionados. Si hay problemas, se informarán aquí. Una vez que haya revisado la configuración, haga clic en Crear para aprovisionar el grupo de acciones.

# REFERENCIAS
