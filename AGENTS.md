# EZOAlerts - AI Development Rules

Este proyecto es un addon para The Elder Scrolls Online (ESO).

El entorno Lua de ESO es limitado. El objetivo es mantener `EZOAlerts` pequeno, estable y facil de integrar en `EZOTools` en el futuro.

## Alcance

- Addon independiente: `EZOAlerts`.
- Avisos visuales en pantalla.
- Mensajes controlados al chat de grupo.
- Panel LibAddonMenu como unica interfaz de configuracion.
- Dos idiomas: ingles y espanol, con opcion `Automatico`.
- Sin menues laterales.
- Sin overlay complejo persistente.
- Sin keybindings.
- Sin interceptar input.

## Reglas obligatorias

- No inventar APIs de ESO.
- No usar librerias externas salvo indicacion expresa.
- Usar `LibAddonMenu-2.0`; `LibChatMessage` es opcional.
- Mantener cambios pequenos y revisables.
- Si se anade un archivo runtime, anadirlo a `EZOAlerts.txt`.
- Evitar globals innecesarias; usar `EZOAlerts = EZOAlerts or {}`.
- Usar prefijo propio: `EZOAlerts_` o `EZOA_`.

## Arquitectura

- Productores de avisos no deben crear controles UI directamente.
- Productores no deben llamar a `StartChatInput` directamente.
- Productores llaman a `EZOAlerts.ShowAlert`, `EZOAlerts.SendGroupAlert`, `EZOAlerts.RegisterAlert` o `EZOAlerts.TriggerAlert`.
- `channels.lua` decide si una alerta sale por pantalla, chat de grupo o ambos.
- `renderer.lua` es la unica capa que dibuja controles en pantalla.
- `group_chat.lua` es la unica capa que envia mensajes al chat de grupo.
- `menu.lua` solo registra opciones LAM y no debe contener reglas de negocio.
- `saved_vars.lua` centraliza defaults.

## Versionado

Para cambios visibles:

- `.\tools\bump-version.ps1 -Patch`
- o `.\tools\bump-version.ps1 -Version x.y.z`

La version visible debe quedar sincronizada entre:

- `EZOAlerts.txt` (`## Version`)
- `modules/core.lua` (`EZOAlerts.ADDON_VERSION`)
- `ezo-addon.json` (`addon.version` y `package.zipName`)

No adivinar `## APIVersion`; cambiarlo solo si el valor actual esta verificado.

Antes de commit:

- `.\tools\bump-version.ps1 -Check`
- `git diff --check`

## Localizacion

- Usar `lang/en.lua` y `lang/es.lua`.
- No hardcodear textos visibles.
- Usar IDs `EZOA_*`.
- Cada clave debe existir en ambos idiomas.

## No hacer

- No crear `Bindings.xml`.
- No registrar keybindings.
- No tocar input global.
- No copiar sistemas de overlay/menu lateral desde `EZOTools`.
- No publicar ni hacer push sin autorizacion explicita.

## Checklist de pruebas

Siempre indicar:

- Carga del addon sin errores Lua.
- `/reloadui`.
- Apertura del panel LAM.
- Cambio de idioma.
- Boton de aviso de prueba.
- Boton de mensaje de grupo de prueba en grupo.
- Teclado y gamepad sin cambios de input.
