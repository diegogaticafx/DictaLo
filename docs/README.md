# DictaLo

Dictado por voz local, minimalista y 100% offline.

- **Minimalista**: un solo script (`transcribe.py`), sin dependencias innecesarias.
- **100% local**: tus datos nunca salen de tu equipo.
- **Acelerado por GPU**: compatible con NVIDIA CUDA 12 (también funciona en CPU).
- **Bajo consumo de RAM**: ~575 MB durante el dictado (modelo `small` en GPU) y ~50 MB en espera.
- **Configurable**: edita el keybind o el LLM en una linea de codigo.
- **Uso Global**: funciona en cualquier ventana activa del sistema.

## Requisitos

- Windows 10/11
- Python 3.12 o superior
- GPU NVIDIA con CUDA 12 o superior (opcional, también funciona en CPU)
- Micrófono

## Instalación

```powershell
.\setup.ps1
```

Este script crea el entorno virtual, instala las dependencias y agrega DictaLo al inicio de Windows.

## Uso

Ejecuta `.\run.bat` (doble clic) o reinicia Windows si ya ejecutaste `setup.ps1`.

- El Keybind por defecto **`Ctrl+Shift+Space`** — Inicia o detiene la grabación.
- Se muestra un pequeño indicador en la esquina superior derecha mientras la grabación está activa.
- El texto transcrito se escribe automáticamente en la ventana activa.

## Configuración

Las variables configurables se encuentran al inicio de `transcribe.py` (líneas 28-32) y en la llamada a `model.transcribe()` (línea 103).

### Variables globales (`transcribe.py`)

| Variable | Valor predeterminado | Valores posibles | Descripción |
|---|---|---|---|
| `HOTKEY` | `'ctrl+shift+space'` | Cualquier combinación válida de `keyboard` | Atajo para iniciar o detener la grabación. |
| `MODEL_SIZE` | `"small"` | `"tiny"`, `"base"`, `"small"`, `"medium"`, `"large-v3"` | Tamaño del modelo Whisper. `tiny` es el más rápido y ligero, mientras que `large-v3` ofrece la mayor precisión. |
| `DEVICE` | `"cuda"` | `"cuda"`, `"cpu"` | Selecciona GPU (CUDA) o CPU. Si no dispones de una GPU NVIDIA, utiliza `"cpu"`. |
| `COMPUTE_TYPE` | `"float16"` | GPU: `"float16"`<br>CPU: `"int8"` | Precisión utilizada por el modelo. En CPU se recomienda `"int8"`. |

### Idioma (`transcribe.py:103`)

```python
segments, info = model.transcribe(audio_data, beam_size=5, language="es")
```

Cambia `"es"` por el código ISO 639-1 del idioma que desees utilizar, por ejemplo: `"en"`, `"fr"`, `"de"`, `"pt"` o `"it"`.

### Configuraciones recomendadas

| Situación | `MODEL_SIZE` | `DEVICE` | `COMPUTE_TYPE` |
|---|---|---|---|
| GPU dedicada (RTX 3060 o superior) | `small` | `cuda` | `float16` |
| GPU de gama baja o integrada | `tiny` o `base` | `cuda` | `float16` |
| CPU moderna | `tiny` o `base` | `cpu` | `int8` |
| CPU de bajo rendimiento | `tiny` | `cpu` | `int8` |

## Estructura del proyecto

```text
whisperlocal/
├── .gitignore
├── LICENSE
├── requirements.txt
├── run.bat              # Ejecutar con doble clic
├── setup.ps1            # Instalación automatizada
├── transcribe.py        # Script principal
├── uninstall.ps1        # Desinstalación
└── docs/
    ├── README.md
    └── agent.md
```

## Desinstalación

```powershell
.\uninstall.ps1
```

Detiene el proceso, elimina el acceso directo del inicio de Windows y, opcionalmente, elimina por completo el proyecto.