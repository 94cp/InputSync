[简体中文](../README.md) · [English](../docs/README.en.md) · [繁體中文](../docs/README.zh-Hant.md) · [日本語](../docs/README.ja.md) · [한국어](../docs/README.ko.md) · [Deutsch](../docs/README.de.md) · [Français](../docs/README.fr.md) · [Español](../docs/README.es.md)

# Sincronía de entrada · InputSync

Sincroniza la fuente de entrada del Mac remoto con la del Mac local mediante Compartir Pantalla de Apple. **Instálala solo en el Mac local.** El Mac remoto no necesita ninguna app ni configuración SSH.

![Demostración de InputSync: interfaz simulada, no una grabación real](assets/inputsync-demo.gif)

## Primeros pasos

1. Descarga el archivo `.dmg` más reciente de [GitHub Releases](https://github.com/94cp/InputSync/releases/latest) del proyecto. Ábrelo, arrastra **InputSync** a **Applications (Aplicaciones)** y abre la app desde esa carpeta. No necesitas Xcode ni compilar el proyecto.
2. Permite el acceso desde la opción de permisos de la app. Según macOS, la categoría corresponde a Accesibilidad o al control del dispositivo y acceso a los datos.
3. Conecta con el Mac remoto mediante Compartir Pantalla de Apple.
4. Activa la sincronización del idioma del teclado en InputSync. También puedes hacerlo en el menú Edición de Compartir Pantalla en el Mac local.
5. Activa la sincronización en InputSync. Cambia la fuente de entrada local y espera aproximadamente un segundo antes de escribir en el Mac remoto.

La app siempre se abre en pausa, incluso al iniciar sesión. Durante la sincronización puede aparecer brevemente un menú remoto.

### Primer inicio bloqueado

Esta versión no tiene firma de Apple Developer ID ni notarización. macOS puede indicar que no puede verificar al desarrollador o comprobar si la app contiene software malicioso.

Si la descargaste de [GitHub Releases](https://github.com/94cp/InputSync/releases/latest) de este proyecto:

1. Abre InputSync una vez desde **Aplicaciones**. Si se bloquea, cierra el aviso sin enviar la app a la papelera.
2. Abre **Ajustes del Sistema → Privacidad y seguridad** y baja hasta **Seguridad**.
3. Busca el mensaje de InputSync y haz clic en **Abrir igualmente**.
4. Si se solicita, introduce tu contraseña de inicio de sesión del Mac o usa Touch ID; después pulsa **Abrir** en la confirmación.

Si falta el botón, intenta abrir la app otra vez y vuelve a Ajustes. Al iniciarse, InputSync aparece en la barra de menús, sin ventana principal. A continuación, concede el permiso de Accesibilidad solicitado por la app: es independiente del permiso para abrirla.

## Cómo funciona

La sincronización del idioma del teclado puede actualizar el indicador remoto sin aplicar el cambio a la app activa. En nuestras pruebas, abrir y cerrar brevemente un menú remoto hizo efectivo el cambio. InputSync automatiza esa operación.

1. Observa las notificaciones de macOS cuando cambia la fuente de entrada local, independientemente de la tecla o el atajo utilizado.
2. Espera el tiempo configurado (0,5 segundos por defecto) para que Compartir Pantalla sincronice primero el idioma.
3. Localiza la pantalla compartida mediante Accesibilidad, hace clic en la parte superior izquierda de la barra de menús remota y envía Escape para cerrar el menú.

Es una solución mediante la interfaz comprobada experimentalmente, no una llamada directa a una API de entrada remota. Requiere que la barra de menús sea accesible en la posición prevista. La aparición breve del menú forma parte del mecanismo.

Puedes mover o redimensionar la ventana. Si cambia durante una actualización pendiente, se omite esa actualización; vuelve a cambiar la fuente después del ajuste. No se han probado todas las combinaciones de pantalla completa y escala.

## Símbolo e idioma

En « Más », elige el símbolo de la barra de menús. El modo automático usa la distribución reconocida del teclado y, si no está disponible, la región del sistema:

- China continental, Taiwán, Hong Kong y Macao: **中/英**
- Japón: **英数 / かな**
- Corea del Sur: **한/영**
- Otras regiones: globo

Es una sugerencia visual, no una lectura de las etiquetas de las teclas. La selección manual tiene prioridad. El símbolo no cambia los atajos ni la fuente de entrada.

La interfaz sigue el idioma de la app configurado en Idioma y región de macOS. Incluye ocho idiomas; para los demás, utiliza inglés.

## Solución de problemas

- **Permiso concedido pero no disponible:** desactiva y vuelve a activar el permiso de esta app y reiníciala. Puede ser necesario volver a conceder permisos tras actualizarse.
- **No se sincroniza:** revisa las opciones de ambas apps, mantén activa la ventana remota o aumenta el tiempo de espera.
- **Registro:** ábrelo desde « Más ».

Verificado con ABC y el pinyin simplificado del sistema en macOS 27.2. No se han probado por completo otros métodos de entrada ni sistemas anteriores. Diseñado para Compartir Pantalla de Apple, sin exigir un modelo de Mac ni un tamaño de ventana fijo.

## Desinstalación

Desactiva la apertura al iniciar sesión, cierra la app y elimínala. Opcionalmente, elimina el registro: `~/Library/Logs/InputSync/events.log`.

## Apoya el desarrollo

Si InputSync te resulta útil, puedes invitarme a un café. ¡Una estrella en GitHub también ayuda!

| WeChat Pay | Alipay |
| :---: | :---: |
| <img src="assets/donate/wechat.png" alt="WeChat Pay" width="180"> | <img src="assets/donate/alipay.png" alt="Alipay" width="180"> |

[Desarrollo](DEVELOPMENT.md)

## Licencia

Distribuido bajo la [licencia MIT](../LICENSE).
