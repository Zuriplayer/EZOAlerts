# Future EZOTools Integration

`EZOAlerts` se ha estructurado para poder integrarse dentro de `EZOTools` sin reescribir el nucleo.

## Integracion prevista

- `modules/alert_registry.lua` -> modulo de dominio de avisos.
- `modules/channels.lua` -> dispatcher reusable para canales.
- `modules/group_chat.lua` -> salida de chat aislada.
- `modules/producers/*.lua` -> productores internos que pueden moverse como modulos de eventos, incluidos avisos locales que no salen por canales publicos.
- `modules/producers/group_leader_zone.lua` -> puede alimentar un boton futuro de viaje manual en EZOTools.
- `modules/renderer.lua` -> capa visual reutilizable o adaptada al overlay de EZOTools.
- `modules/menu.lua` -> seccion LAM registrada dentro del sistema de settings de EZOTools.
- `lang/*.lua` -> claves `EZOA_*` migrables o aliasables.

## Reglas para facilitar la migracion

- Mantener API publica pequena.
- No depender de rutas de addon hardcodeadas.
- No mezclar avisos con menues laterales.
- No asumir keybindings.
- Evitar estados globales fuera de `EZOAlerts`.

## Superficie publica

```lua
EZOAlerts.ShowAlert(text, kind, options)
EZOAlerts.SendGroupAlert(text, options)
EZOAlerts.RegisterAlert(id, definition)
EZOAlerts.TriggerAlert(id, context)
```
