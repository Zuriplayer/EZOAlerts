# EZOAlerts

**Beta pública.** EZOAlerts es un addon independiente para The Elder Scrolls Online que ofrece alertas modulares en pantalla y notificaciones controladas al chat de grupo dentro de la familia de addons EZO.

Prefer English? Read the [README in English](README.md).

Soporte, errores y sugerencias: https://discord.gg/ekw8zUAcRm


## Alcance Actual

EZOAlerts proporciona un sistema pequeño de avisos con productores internos, una ventana HUD compartida y salida controlada al chat de grupo. Cuando EZOCore está activo, su configuración se integra en `Settings > EZO`; en caso contrario registra un panel independiente de LibAddonMenu.

El addon se centra actualmente en avisos de grupo y coherencia de rol. No sustituye la interfaz de combate, los marcos de grupo, las barras de habilidades ni otros sistemas de ESO.

## Metadatos de versión

- Versión del addon: `0.1.20`
- AddOnVersion: `10020`
- APIVersion: `101049 101050`
- Estado: beta pública

## Requisitos

- The Elder Scrolls Online.
- LibAddonMenu-2.0.
- Opcional: EZOCore para la configuración central en `Settings > EZO`.
- Opcional: LibChatMessage para mensajes locales del addon más limpios.
- Opcional: LibDebugLogger y DebugLogViewer para la salida del log de combate.

## Instalación

1. Descarga o clona este repositorio.
2. Coloca la carpeta `EZOAlerts` en tu carpeta de addons de ESO:
   - `Documents/Elder Scrolls Online/live/AddOns/EZOAlerts`
   - o `Documents/Elder Scrolls Online/pts/AddOns/EZOAlerts`
3. Asegúrate de que `LibAddonMenu-2.0` está instalado y activado.
4. Inicia ESO o ejecuta `/reloadui`.
5. Configura el addon desde `Settings > EZO > EZOAlerts`. Sin EZOCore, usa el panel independiente `Configuración > Addons > EZOAlerts`.

## Funciones Implementadas

- Ventana compartida de avisos en pantalla:
  - Visibilidad solo en HUD/HUD UI.
  - Estilos de información, warning y error.
  - Previsualización movible desde LibAddonMenu.
  - Ajustes de escala, ancla de posición y duración de avisos temporales.
  - Texto de acción para teclado/gamepad cuando ESO expone el modo de entrada.

- Canal controlado de chat de grupo:
  - Selector global para chat de grupo.
  - Protección para que los mensajes generados de grupo solo funcionen estando en grupo.
  - Usa la entrada de chat de ESO para texto de grupo; según el comportamiento de ESO, puede que el jugador tenga que confirmar manualmente la línea preparada.

- Avisos de cofres:
  - Detecta apertura de cofres mediante eventos de ganzúa y botín.
  - Informa del jugador y de la calidad de cerradura detectada.
  - Solo genera mensajes estando en grupo.
  - Incluye activación, salida al chat de grupo y tiempo de espera configurables.

- Avisos de sacos pesados:
  - Detecta sacos pesados mediante información del objetivo de botín.
  - Solo genera mensajes estando en grupo.
  - Incluye activación, salida al chat de grupo y tiempo de espera configurables.

- Avisos de guild compartida:
  - Compara los miembros del grupo con tus cinco guilds de ESO.
  - Muestra un mensaje solo local con las guilds compartidas con cada miembro detectado.
  - Puede suprimir la detección si el líder del grupo comparte guild contigo, para reducir ruido durante eventos de guild.

- Aviso de zona del líder:
  - Muestra un mensaje local cuando el líder del grupo cambia de zona o instancia después de que el grupo ya esté formado.
  - Puede ignorar avisos cuando ya estás en la misma zona.
  - Incluye ajuste de tiempo de espera.

- Avisos de comprobación de rol:
  - Compara el rol de grupo seleccionado con armas equipadas y señales básicas de habilidades sloteadas.
  - Las alarmas de tanque comprueban espada y escudo o bastón de hielo; los warnings comprueban un taunt sloteado.
  - Las alarmas de healer comprueban bastón de restauración; los warnings comprueban habilidades de curación conocidas.
  - Las alarmas/warnings de DD comprueban armas claramente de soporte o señales de taunt.
  - Puede mostrar solo alarmas, alarmas y warnings, o desactivarse.
  - Puede limitarse a juego en grupo.
  - Puede silenciarse en configuración o durante la sesión desde la ventana de aviso.
  - No usa detección de sets.

- Localización:
  - Inglés y español.
  - El modo automático sigue el idioma del cliente de ESO; los idiomas no soportados usan inglés.

- Log central opcional:
  - Un único ajuste global `Log`.
  - Los productores registran eventos ocurridos durante combate en un bus de log común.
  - La salida del log se agrupa y se vuelca en LibDebugLogger/DebugLogViewer al terminar el combate si está disponible.
  - No imprime resúmenes de log en la ventana normal de chat.

## Opciones Principales de Configuración

Las secciones de configuración usan cabeceras informativas de estilo EZO con un icono morado de ayuda. La ayuda general está en el tooltip de la cabecera; la ayuda específica de cada ajuste está en el tooltip del propio campo.

- General:
  - Idioma: automático, inglés o español.
  - Log: activa un único log compartido post-combate para DebugLogViewer.

- Avisos:
  - Activar avisos en pantalla.
  - Activar avisos al chat de grupo.
  - Duración de avisos temporales en segundos.
  - Escala del aviso.
  - Ancla de posición en pantalla.
  - Mover ventana de avisos.
  - Mostrar aviso de prueba.
  - Enviar mensaje de grupo de prueba.

- Avisos generados:
  - Avisos de cofres, salida al chat de grupo y tiempo de espera.
  - Avisos de sacos pesados, salida al chat de grupo y tiempo de espera.
  - Detección de miembros de grupo con guild compartida.
  - Supresión de detección de guild compartida si el líder comparte guild contigo.
  - Aviso de zona/instancia del líder, ignorar misma zona y tiempo de espera.
  - Modo de comprobación de rol, silenciar, solo en grupo y tiempo de espera.

## Límites de Seguridad

- No automatiza combate.
- No viaja automáticamente.
- No cambia el rol automáticamente.
- No escanea sets.
- No intercepta input global.
- No registra keybindings propios.
- No sustituye barras de habilidades, marcos de grupo ni menús de ESO.
- No publica en Discord ni ejecuta workflows externos desde el addon.

Los avisos al chat de grupo están limitados intencionadamente por la configuración del addon, el estado de grupo y el comportamiento del chat de ESO. EZOAlerts no intenta saltarse las restricciones de input o chat de ESO.

## Pruebas Recomendadas de Beta

- Cargar el addon sin errores Lua.
- Ejecutar `/reloadui`.
- Abrir `Settings > EZO > EZOAlerts` y confirmar que los controles permanecen dentro de la ventana EZO.
- Con EZOCore desactivado, confirmar que está disponible el panel independiente de LibAddonMenu.
- Cambiar idioma entre automático, inglés y español.
- Usar el aviso de prueba en pantalla.
- Usar el mensaje de grupo de prueba estando en grupo.
- Confirmar que los mensajes de cofres y sacos pesados no se activan fuera de grupo.
- Confirmar que los avisos de guild compartida son solo locales.
- Confirmar que los avisos de zona del líder no viajan automáticamente.
- Probar la comprobación de rol con rol tanque, healer y DD.
- Probar confirmar recibido y silenciar sesión en la ventana de rol.
- Probar el texto de acción en teclado/ratón y modo gamepad.
- Confirmar que la ventana de avisos aparece solo en escenas normales HUD/HUD UI.
- Confirmar que la previsualización de mover ventana no queda activa tras `/reloadui`.

## Comprobaciones de Desarrollo

Comprobaciones locales útiles:

```powershell
.\tools\bump-version.ps1 -Check
git diff --check
```

El script de empaquetado existe para paquetes de release, pero los ZIP de release se escriben en `dist/`, que está ignorado por Git:

```powershell
.\tools\build-addon-package.ps1 -Force
```

## Licencia

MIT. Consulta [LICENSE](LICENSE).
