# DictaLo

Dictado por voz local, minimalista y 100% offline.

- **Minimalista**: un solo script (`transcribe.py`), sin dependencias innecesarias
- **Bajo consumo de RAM**: ~575 MB durante dictado (modelo `small` en GPU), ~50 MB en espera
- **100% local**: tus datos nunca salen de tu PC
- **GPU acelerado**: NVIDIA CUDA 12 (funciona también en CPU)

## Requisitos

- Windows 10/11
- Python 3.12+
- GPU NVIDIA con CUDA 12 o superior (opcional, funciona en CPU)
- Micrófono

## Instalación

```powershell
.\setup.ps1
```

Crea el entorno virtual, instala dependencias y agrega whisperlocal al inicio de Windows.

## Uso

Ejecutá `.\run.bat` (doble click) o reiniciá Windows si ya corriste `setup.ps1`.

- **`Ctrl+Shift+Space`** — iniciar / detener grabación
- Aparece un overlay pequeño en la esquina superior derecha mientras grabás
- El texto transcrito se escribe automáticamente en la ventana activa

## Configuración

Las variables editables están al inicio de `transcribe.py` (líneas 28-32) y en la llamada a `model.transcribe()` (línea 103):

### Variables globales (`transcribe.py`)

| Variable | Valor por defecto | Valores posibles | Descripción |
|---|---|---|---|
| `HOTKEY` | `'ctrl+shift+space'` | Cualquier combinación válida de `keyboard` | Atajo para iniciar/detener grabación |
| `MODEL_SIZE` | `"small"` | `"tiny"`, `"base"`, `"small"`, `"medium"`, `"large-v3"` | Tamaño del modelo Whisper. `tiny` es más rápido y liviano, `large-v3` más preciso |
| `DEVICE` | `"cuda"` | `"cuda"`, `"cpu"` | GPU (CUDA) o CPU. Si no tenés NVIDIA, cambiá a `"cpu"` |
| `COMPUTE_TYPE` | `"float16"` | GPU: `"float16"`, CPU: `"int8"` | Precisión del modelo. En CPU usar `"int8"` |

### Idioma (`transcribe.py:103`)

```python
segments, info = model.transcribe(audio_data, beam_size=5, language="es")
```

Cambiar `"es"` por el código ISO 639-1 del idioma deseado: `"en"`, `"fr"`, `"de"`, `"pt"`, `"it"`, etc.

### Combinaciones recomendadas

| Situación | `MODEL_SIZE` | `DEVICE` | `COMPUTE_TYPE` |
|---|---|---|---|
| GPU dedicada (RTX 3060+) | `small` | `cuda` | `float16` |
| GPU baja o integrada | `tiny` o `base` | `cuda` | `float16` |
| CPU moderna | `tiny` o `base` | `cpu` | `int8` |
| CPU lenta | `tiny` | `cpu` | `int8` |

## Estructura del proyecto

```
whisperlocal/
├── .gitignore
├── LICENSE
├── requirements.txt
├── run.bat              # Lanzador (doble click)
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

Detiene el proceso, elimina el acceso directo de inicio y opcionalmente borra todo el proyecto.
