"""
whisperlocal - Voice dictation using local Whisper.
Press Ctrl+Shift+Space to start/stop recording, transcribes and types the text.
Runs in background with pythonw.exe (no console window).
Shows a small overlay window while recording.
"""

import os
import sys

# Add CUDA 12 runtime DLLs to PATH so ctranslate2 can find them
_cuda_dirs = [
    os.path.join(sys.prefix, "Lib", "site-packages", "nvidia", "cublas", "bin"),
    os.path.join(sys.prefix, "Lib", "site-packages", "nvidia", "cuda_runtime", "bin"),
]
for _d in _cuda_dirs:
    if os.path.isdir(_d):
        os.environ["PATH"] = _d + os.pathsep + os.environ.get("PATH", "")

import tkinter as tk
import sounddevice as sd
import numpy as np
import keyboard
import threading
import time
from faster_whisper import WhisperModel

SAMPLE_RATE = 16000
HOTKEY = 'ctrl+shift+space'
MODEL_SIZE = "small"
DEVICE = "cuda"
COMPUTE_TYPE = "float16"

state = "idle"
is_recording = False
audio_buffer = []
model = None
state_lock = threading.Lock()

overlay = None
overlay_label = None


def create_overlay():
    global overlay, overlay_label
    overlay = tk.Toplevel()
    overlay.overrideredirect(True)
    overlay.attributes('-topmost', True)
    overlay.attributes('-alpha', 0.9)
    overlay.configure(bg="#2d2d2d", bd=0, highlightthickness=0)

    screen_w = overlay.winfo_screenwidth()
    overlay.geometry(f"280x40+{screen_w - 300}+20")

    overlay_label = tk.Label(
        overlay,
        text=f"🎤 Grabando... {HOTKEY}",
        fg="white",
        bg="#2d2d2d",
        font=("Segoe UI", 11),
    )
    overlay_label.pack(fill="both", expand=True, padx=14, pady=8)
    overlay.withdraw()


def show_overlay(text):
    if overlay:
        overlay_label.config(text=text)
        overlay.deiconify()
        overlay.lift()


def hide_overlay():
    if overlay:
        overlay.withdraw()


def load_model():
    global model
    model = WhisperModel(MODEL_SIZE, device=DEVICE, compute_type=COMPUTE_TYPE)


def record_audio():
    global is_recording, audio_buffer
    audio_buffer = []

    def callback(indata, frames, time, status):
        if is_recording:
            audio_buffer.append(indata.copy())

    with sd.InputStream(samplerate=SAMPLE_RATE, channels=1, callback=callback, dtype='float32'):
        while is_recording:
            sd.sleep(100)


def transcribe_and_type():
    global state
    try:
        if not audio_buffer:
            return

        audio_data = np.concatenate(audio_buffer, axis=0).flatten()
        segments, info = model.transcribe(audio_data, beam_size=5, language="es")
        text = " ".join(segment.text for segment in segments)

        if text.strip():
            time.sleep(0.3)
            keyboard.write(text)
    finally:
        with state_lock:
            state = "idle"
        root.after(0, hide_overlay)


def toggle_recording():
    global is_recording, state
    with state_lock:
        if state == "recording":
            is_recording = False
            state = "transcribing"
            root.after(0, lambda: show_overlay("⏹️ Transcribiendo..."))
            threading.Thread(target=transcribe_and_type, daemon=True).start()
        elif state in ("idle", "transcribing"):
            state = "recording"
            is_recording = True
            root.after(0, lambda: show_overlay(f"🎤 Grabando... {HOTKEY}"))
            threading.Thread(target=record_audio, daemon=True).start()


def main():
    global root
    root = tk.Tk()
    root.withdraw()

    create_overlay()
    load_model()

    keyboard.add_hotkey(HOTKEY, toggle_recording)
    root.mainloop()


if __name__ == "__main__":
    main()
