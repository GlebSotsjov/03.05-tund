import tkinter as tk
from tkinter import ttk
import sqlite3

GENRES = ["Fantaasia", "Detektiivid", "Armuasjad", "Erootika", "Thrillerid", "Horror", "Koomiksid ja manga", "Seiklused", "Proosa", "Luule","Fiction"]

class LibraryApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Библиотека")
        self.root.geometry("1000x800")
        self.root.configure(bg="#8A2BE2")

        self.style = ttk.Style()
        self.style.theme_use("clam")
        self.style.configure("TFrame", background="#8A2BE2")
        self.style.configure("TLabel", background="#8A2BE2", foreground="#FFFFFF")
        self.style.configure("TButton", background="#4B0082", foreground="white", padding=10)
        
        self.selected_table = tk.StringVar(value="Books")

        self.create_widgets()

    def create_widgets(self):
        self.interaction_frame = ttk.Frame(self.root)
        self.interaction_frame.pack(padx=20, pady=20, anchor="w")

        self.table_selector_frame = ttk.Frame(self.interaction_frame)
        self.table_selector_frame.pack(anchor="w", pady=5)

        self.radio_books = ttk.Radiobutton(self.table_selector_frame, text="Books", variable=self.selected_table, value="Books", command=self.load_data)
        self.radio_books.pack(anchor="w")
        self.radio_authors = ttk.Radiobutton(self.table_selector_frame, text="Authors", variable=self.selected_table, value="Authors", command=self.load_data)
        self.radio_authors.pack(anchor="w")
        self.radio_genres = ttk.Radiobutton(self.table_selector_frame, text="Genres", variable=self.selected_table, value="Genres", command=self.load_data)
        self.radio_genres.pack(anchor="w")

        self.add_entry_fields()

        self.data_frame = ttk.Frame(self.root)
        self.data_frame.pack(padx=20, pady=20, fill=tk.BOTH, expand=True)

        self.load_data()

    def add_entry_fields(self):
        self.entry_title = ttk.Entry(self.interaction_frame, width=30, style="TEntry")
        self.entry_title.pack(anchor="w", pady=5)
        self.entry_title.insert(0, "Название")

        self.date_frame = ttk.Frame(self.interaction_frame)
        self.date_frame.pack(anchor="w", pady=5)

        self.day_var = tk.StringVar()
        self.month_var = tk.StringVar()
        self.year_var = tk.StringVar()

        ttk.Label(self.date_frame, text="День:", style="TLabel").grid(row=0, column=0, padx=5)
        self.day_combo = ttk.Combobox(self.date_frame, textvariable=self.day_var, values=[str(i) for i in range(1, 32)], width=5, style="TCombobox")
        self.day_combo.grid(row=0, column=1, padx=5)
        self.day_combo.set("1")

        ttk.Label(self.date_frame, text="Месяц:", style="TLabel").grid(row=0, column=2, padx=5)
        self.month_combo = ttk.Combobox(self.date_frame, textvariable=self.month_var, values=["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"], width=10, style="TCombobox")
        self.month_combo.grid(row=0, column=3, padx=5)
        self.month_combo.set("Январь")

        ttk.Label(self.date_frame, text="Год:", style="TLabel").grid(row=0, column=4, padx=5)
        self.year_combo = ttk.Combobox(self.date_frame, textvariable=self.year_var, values=[str(i) for i in range(1900, 2101)], width=7, style="TCombobox")
        self.year_combo.grid(row=0, column=5, padx=5)
        self.year_combo.set("2022")

        self.entry_author = ttk.Entry(self.interaction_frame, width=30, style="TEntry")
        self.entry_author.pack(anchor="w", pady=5)
        self.entry_author.insert(0, "Автор")

        self.genre_combo = ttk.Combobox(self.interaction_frame, values=GENRES, style="TCombobox")
        self.genre_combo.pack(anchor="w", pady=5)
        self.genre_combo.set(GENRES[0])

        self.add_button = ttk.Button(self.interaction_frame, text="Добавить", command=self.add_entry, style="TButton")
        self.add_button.pack(anchor="w", pady=5)

        self.delete_button = ttk.Button(self.interaction_frame, text="Удалить", command=self.delete_entry, style="TButton")
        self.delete_button.pack(anchor="w", pady=5)

        self.edit_button = ttk.Button(self.interaction_frame, text="Редактировать", command=self.edit_entry, style="TButton")
        self.edit_button.pack(anchor="w", pady=5)

        self.clear_restore_button = ttk.Button(self.interaction_frame, text="Очистить и восстановить", command=self.clear_and_restore_table, style="TButton")
        self.clear_restore_button.pack(anchor="w", pady=5)

        self.selected_item_id = None

    def add_entry(self):
        title = self.entry_title.get()
        day = self.day_var.get()
        month = self.month_var.get()
        year = self.year_var.get()
        author = self.entry_author.get()
        genre = self.genre_combo.get()

        date = f"{year}-{month}-{day}"

        selected_table = self.selected_table.get()

        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()

            if selected_table == "Books":
                cursor.execute("SELECT author_id FROM Authors WHERE author_name=?", (author,))
                author_row = cursor.fetchone()
                if not author_row:
                    cursor.execute("INSERT INTO Authors (author_name, date_of_birth) VALUES (?, '')", (author,))
                    cursor.execute("SELECT last_insert_rowid()")
                    author_id = cursor.fetchone()[0]
                else:
                    author_id = author_row[0]

                cursor.execute("SELECT genre_id FROM Genres WHERE genre_name=?", (genre,))
                genre_row = cursor.fetchone()
                if not genre_row:
                    cursor.execute("INSERT INTO Genres (genre_name) VALUES (?)", (genre,))
                    cursor.execute("SELECT last_insert_rowid()")
                    genre_id = cursor.fetchone()[0]
                else:
                    genre_id = genre_row[0]

                cursor.execute("INSERT INTO Books (title, date_of_publication, author_id, genre_id) VALUES (?, ?, ?, ?)",
                               (title, date, author_id, genre_id))
            elif selected_table == "Authors":
                cursor.execute("INSERT INTO Authors (author_name, date_of_birth) VALUES (?, ?)", (author, date))
            elif selected_table == "Genres":
                cursor.execute("INSERT INTO Genres (genre_name) VALUES (?)", (genre,))

        self.load_data()

    def delete_entry(self):
        selected_table = self.selected_table.get()
        selected_item = self.data_tree.focus()
        if selected_item:
            item_values = self.data_tree.item(selected_item)["values"]
            with sqlite3.connect('library.db') as connection:
                cursor = connection.cursor()
                if selected_table == "Books":
                    book_id = item_values[4]
                    cursor.execute("DELETE FROM Books WHERE book_id=?", (book_id,))
                elif selected_table == "Authors":
                    author_id = item_values[0]
                    cursor.execute("DELETE FROM Authors WHERE author_id=?", (author_id,))
                elif selected_table == "Genres":
                    genre_id = item_values[0]
                    cursor.execute("DELETE FROM Genres WHERE genre_id=?", (genre_id,))
            self.load_data()

    def edit_entry(self):
        selected_item = self.data_tree.focus()
        if selected_item:
            item_values = self.data_tree.item(selected_item)["values"]
            self.entry_title.delete(0, tk.END)
            self.entry_title.insert(0, item_values[0])

            date_parts = item_values[1].split("-")
            self.year_var.set(date_parts[0])
            self.month_combo.set(date_parts[1])
            self.day_combo.set(date_parts[2])

            self.entry_author.delete(0, tk.END)
            self.entry_author.insert(0, item_values[2])

            self.genre_combo.set(item_values[3])

            self.add_button.config(text="Сохранить", command=self.save_edit)
            self.selected_item_id = item_values[4]

    def save_edit(self):
        title = self.entry_title.get()
        day = self.day_var.get()
        month = self.month_var.get()
        year = self.year_var.get()
        author = self.entry_author.get()
        genre = self.genre_combo.get()

        date = f"{year}-{month}-{day}"

        selected_item_id = self.selected_item_id

        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()

            cursor.execute("SELECT author_id FROM Authors WHERE author_name=?", (author,))
            author_row = cursor.fetchone()
            if not author_row:
                cursor.execute("INSERT INTO Authors (author_name, date_of_birth) VALUES (?, '')", (author,))
                cursor.execute("SELECT last_insert_rowid()")
                author_id = cursor.fetchone()[0]
            else:
                author_id = author_row[0]

            cursor.execute("SELECT genre_id FROM Genres WHERE genre_name=?", (genre,))
            genre_row = cursor.fetchone()
            if not genre_row:
                cursor.execute("INSERT INTO Genres (genre_name) VALUES (?)", (genre,))
                cursor.execute("SELECT last_insert_rowid()")
                genre_id = cursor.fetchone()[0]
            else:
                genre_id = genre_row[0]

            cursor.execute("UPDATE Books SET title=?, date_of_publication=?, author_id=?, genre_id=? WHERE book_id=?",
                           (title, date, author_id, genre_id, selected_item_id))

        self.load_data()
        self.add_button.config(text="Добавить", command=self.add_entry)
        self.selected_item_id = None

    def load_data(self):
        selected_table = self.selected_table.get()
        for widget in self.data_frame.winfo_children():
            widget.destroy()

        if selected_table == "Books":
            columns = ("title", "date_of_publication", "author_name", "genre_name", "book_id")
            self.data_tree = ttk.Treeview(self.data_frame, columns=columns, show="headings")
            for col in columns:
                self.data_tree.heading(col, text=col)
                self.data_tree.column(col, width=120, anchor=tk.W)
            self.data_tree.pack(fill=tk.BOTH, expand=True)
            self.data_tree.bind("<Double-1>", self.on_double_click)
            with sqlite3.connect('library.db') as connection:
                cursor = connection.cursor()
                cursor.execute('''
                    SELECT Books.title, Books.date_of_publication, Authors.author_name, Genres.genre_name, Books.book_id
                    FROM Books
                    JOIN Authors ON Books.author_id = Authors.author_id
                    JOIN Genres ON Books.genre_id = Genres.genre_id
                ''')
                rows = cursor.fetchall()
                for row in rows:
                    self.data_tree.insert("", tk.END, values=row)
        elif selected_table == "Authors":
            columns = ("author_id", "author_name", "date_of_birth")
            self.data_tree = ttk.Treeview(self.data_frame, columns=columns, show="headings")
            for col in columns:
                self.data_tree.heading(col, text=col)
                self.data_tree.column(col, width=120, anchor=tk.W)
            self.data_tree.pack(fill=tk.BOTH, expand=True)
            self.data_tree.bind("<Double-1>", self.on_double_click)
            with sqlite3.connect('library.db') as connection:
                cursor = connection.cursor()
                cursor.execute('SELECT author_id, author_name, date_of_birth FROM Authors')
                rows = cursor.fetchall()
                for row in rows:
                    self.data_tree.insert("", tk.END, values=row)
        elif selected_table == "Genres":
            columns = ("genre_id", "genre_name")
            self.data_tree = ttk.Treeview(self.data_frame, columns=columns, show="headings")
            for col in columns:
                self.data_tree.heading(col, text=col)
                self.data_tree.column(col, width=120, anchor=tk.W)
            self.data_tree.pack(fill=tk.BOTH, expand=True)
            self.data_tree.bind("<Double-1>", self.on_double_click)
            with sqlite3.connect('library.db') as connection:
                cursor = connection.cursor()
                cursor.execute('SELECT genre_id, genre_name FROM Genres')
                rows = cursor.fetchall()
                for row in rows:
                    self.data_tree.insert("", tk.END, values=row)
        self.highlight_columns()

    def highlight_columns(self):
        selected_table = self.selected_table.get()

        columns_to_highlight = {
            "Books": ("date_of_publication",),
            "Authors": ("author_name",),
            "Genres": ("genre_name",)
        }

        self.data_tree.tag_configure("highlighted", background="#FFD700")

        for item in self.data_tree.get_children():
            values = self.data_tree.item(item, "values")
            for col, value in zip(self.data_tree["columns"], values):
                if col in columns_to_highlight[selected_table]:
                    self.data_tree.item(item, tags=("highlighted",))

    def on_double_click(self, event):
        self.edit_entry()

    def clear_and_restore_table(self):
        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()

            cursor.execute('DELETE FROM Books')
            cursor.execute('DELETE FROM Authors')
            cursor.execute('DELETE FROM Genres')

            cursor.execute('''
                INSERT INTO Authors (author_name, date_of_birth) VALUES 
                ('Ernest Hemingway', '1899-07-21'),
                ('Jane Austen', '1775-12-16')
            ''')
            cursor.execute('''
                INSERT INTO Genres (genre_name) VALUES 
                ('Fiction'), 
                ('Non-Fiction')
            ''')
            cursor.execute('''
                INSERT INTO Books (title, date_of_publication, author_id, genre_id) VALUES 
                ('The Old Man and the Sea', '1952-09-01', 1, 1),
                ('Pride and Prejudice', '1813-01-28', 2, 1)
            ''')

        self.load_data()

if __name__ == "__main__":
    root = tk.Tk()
    app = LibraryApp(root)
    root.mainloop()
