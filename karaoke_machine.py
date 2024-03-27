import tkinter as tk
from tkinter import ttk, messagebox
from PIL import Image, ImageTk
import wave
import pyaudio
import threading

# Global variables for song playback and GUI elements
current_song = None
song_thread = None
is_paused = threading.Event()
stream = None
player_window = None
pause_button = None
song_label = None
progress_bar = None
lyrics_label = None
total_length = 1
lyrics_lines = []
BPM = 89
SECONDS_PER_BEAT = 60 / BPM

def play_song(song_file):
    global current_song, stream, is_paused, total_length, lyrics_lines

    if current_song != song_file:
        stop_song()

    current_song = song_file
    is_paused.clear()

    try:
        wf = wave.open(song_file, 'rb')
    except FileNotFoundError:
        messagebox.showerror("Error", f"File {song_file} not found.")
        return

    # Load lyrics
    lyrics_file = song_file.replace('.wav', '.txt')
    with open(lyrics_file, 'r') as file:
        lyrics_lines = file.readlines()
    update_lyrics_display("")

    p = pyaudio.PyAudio()
    stream = p.open(format=p.get_format_from_width(wf.getsampwidth()),
                    channels=wf.getnchannels(),
                    rate=wf.getframerate(),
                    output=True)

    total_length = wf.getnframes() / wf.getframerate()
    update_player_window(song_file)

    data = wf.readframes(1024)
    play_time = 0
    lyrics_index = 0
            
    while data:
        if is_paused.is_set():
            continue

        stream.write(data)
        data = wf.readframes(1024)
        play_time += (1024 / wf.getframerate())
        update_progress(play_time / total_length)

        # Update lyrics based on the adjusted BPM
        if play_time >= lyrics_index * SECONDS_PER_BEAT and lyrics_index < len(lyrics_lines):
            update_lyrics_display(lyrics_lines[lyrics_index].strip())
            lyrics_index += 1
            
    

    stop_song()

def update_player_window(song_file):
    global player_window, pause_button, song_label, progress_bar, lyrics_label
    if player_window is None:
        player_window = tk.Toplevel()
        player_window.title("Now Playing")

    song_number = int(song_file[-5])
    img = Image.open(f"Song {song_number}.jpeg")
    img = img.resize((200, 200), Image.Resampling.LANCZOS)
    photo = ImageTk.PhotoImage(img)

    if song_label is None:
        song_label = tk.Label(player_window, image=photo)
        song_label.image = photo
        song_label.pack()

    if progress_bar is None:
        progress_bar = ttk.Progressbar(player_window, orient='horizontal', length=200, mode='determinate')
        progress_bar.pack()

    if pause_button is None:
        pause_button = tk.Button(player_window, text="⏸", command=pause_or_resume_song)
        pause_button.pack()
        tk.Button(player_window, text="Restart", command=lambda: restart_song(song_file)).pack()

    if lyrics_label is None:
        lyrics_label = tk.Label(player_window, text="", font=("Helvetica", 12))
        lyrics_label.pack()

def update_progress(progress):
    if progress_bar is not None:
        progress_bar['value'] = progress * 100

def update_lyrics_display(lyrics_line):
    if lyrics_label is not None:
        lyrics_label.config(text=lyrics_line)

def handle_song_selection(song_number):
    global song_thread
    song_file = f"Song {song_number}.wav"
    song_thread = threading.Thread(target=play_song, args=(song_file,))
    song_thread.start()

def pause_or_resume_song():
    global is_paused, pause_button
    if is_paused.is_set():
        pause_button.config(text="⏸")
        is_paused.clear()
    else:
        pause_button.config(text="⏵")
        is_paused.set()

def restart_song(song_file):
    if messagebox.askyesno("Restart", "Do you really want to restart the current song?"):
        stop_song()
        handle_song_selection(int(song_file[-5]))

def stop_song():
    global stream, current_song, is_paused
    if stream is not None:
        stream.stop_stream()
        stream.close()
        current_song = None
        is_paused.clear()

def create_gui():
    root = tk.Tk()
    root.title("Song Selector")
    root.configure(bg='white')
    root.geometry('1000x500')

    for i in range(1, 6):
        tk.Button(root, text=f"Play Song {i}", bg='white', fg='black',
                  command=lambda song_number=i: handle_song_selection(song_number)).pack(pady=10, fill=tk.X, padx=50)

    root.mainloop()

if __name__ == "__main__":
    create_gui()