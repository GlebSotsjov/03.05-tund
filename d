import tkinter as tk
from tkinter import ttk
import sqlite3

class LibraryApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Библиотека")  # Устанавливаем заголовок окна
        self.root.geometry("1000x800")  # Устанавливаем размеры окна
        self.root.configure(bg="#8A2BE2")  # Устанавливаем фиолетовый фон для окна

        self.style = ttk.Style()  # Создаем объект стиля
        self.style.theme_use("clam")  # Используем стандартную тему
        self.style.configure("TFrame", background="#8A2BE2")  # Устанавливаем цвет фона для всех рамок
        self.style.configure("TLabel", background="#8A2BE2", foreground="#FFFFFF")  # Устанавливаем цвет фона и текста для всех надписей
        self.style.configure("TButton", background="#4B0082", foreground="white", padding=10)  # Устанавливаем цвет кнопок

        self.create_widgets()

    def create_widgets(self):
        # Создаем рамку для взаимодействия с пользователем
        self.interaction_frame = ttk.Frame(self.root)
        self.interaction_frame.pack(padx=20, pady=20, anchor="w")

        # Создаем комбо-бокс для выбора таблицы
        self.table_selector = ttk.Combobox(self.interaction_frame, values=["Books", "Authors", "Genres"], style="TCombobox")
        self.table_selector.pack(anchor="w", pady=5)
        self.table_selector.current(0)

        # Добавляем поля ввода для данных
        self.add_entry_fields()

        # Создаем рамку для отображения данных
        self.data_frame = ttk.Frame(self.root)
        self.data_frame.pack(padx=20, pady=20)

        # Загружаем данные из базы данных
        self.load_data()

    def add_entry_fields(self):
        # Поле ввода для названия
        self.entry_title = ttk.Entry(self.interaction_frame, width=30, style="TEntry")
        self.entry_title.pack(anchor="w", pady=5)
        self.entry_title.insert(0, "Название")

        # Создаем рамку для ввода даты
        self.date_frame = ttk.Frame(self.interaction_frame)
        self.date_frame.pack(anchor="w", pady=5)

        # Переменные для хранения выбранной даты
        self.day_var = tk.StringVar()
        self.month_var = tk.StringVar()
        self.year_var = tk.StringVar()

        # Создаем метки и комбо-боксы для даты
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

        # Поле ввода для автора
        self.entry_author = ttk.Entry(self.interaction_frame, width=30, style="TEntry")
        self.entry_author.pack(anchor="w", pady=5)
        self.entry_author.insert(0, "Автор")

        # Поле ввода для жанра
        self.entry_genre = ttk.Entry(self.interaction_frame, width=30, style="TEntry")
        self.entry_genre.pack(anchor="w", pady=5)
        self.entry_genre.insert(0, "Жанр")

        # Кнопка для добавления записи
        self.add_button = ttk.Button(self.interaction_frame, text="Добавить", command=self.add_entry, style="TButton")
        self.add_button.pack(anchor="w", pady=5)

        # Кнопка для удаления записи
        self.delete_button = ttk.Button(self.interaction_frame, text="Удалить", command=self.delete_entry, style="TButton")
        self.delete_button.pack(anchor="w", pady=5)

        # Кнопка для редактирования записи
        self.edit_button = ttk.Button(self.interaction_frame, text="Редактировать", command=self.edit_entry, style="TButton")
        self.edit_button.pack(anchor="w", pady=5)

        # Кнопка для очистки и восстановления таблицы
        self.clear_restore_button = ttk.Button(self.interaction_frame, text="Очистить и восстановить", command=self.clear_and_restore_table, style="TButton")
        self.clear_restore_button.pack(anchor="w", pady=5)

        # Переменная для хранения ID выбранной записи для редактирования
        self.selected_item_id = None

    def add_entry(self):
        # Получаем данные из полей ввода
        title = self.entry_title.get()
        day = self.day_var.get()
        month = self.month_var.get()
        year = self.year_var.get()
        author = self.entry_author.get()
        genre = self.entry_genre.get()

        # Форматируем дату
        date = f"{year}-{month}-{day}"

        # Получаем выбранную таблицу
        selected_table = self.table_selector.get()

        # Подключаемся к базе данных
        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()

            # Проверяем, существует ли автор
            cursor.execute("SELECT author_id FROM Authors WHERE author_name=?", (author,))
            author_row = cursor.fetchone()

            # Если автора нет, добавляем его
            if not author_row:
                cursor.execute("INSERT INTO Authors (author_name, date_of_birth) VALUES (?, '')", (author,))
                cursor.execute("SELECT last_insert_rowid()")
                author_id = cursor.fetchone()[0]
            else:
                author_id = author_row[0]

            # Проверяем, существует ли жанр
            cursor.execute("SELECT genre_id FROM Genres WHERE genre_name=?", (genre,))
            genre_row = cursor.fetchone()

            # Если жанра нет, добавляем его
            if not genre_row:
                cursor.execute("INSERT INTO Genres (genre_name) VALUES (?)", (genre,))
                cursor.execute("SELECT last_insert_rowid()")
                genre_id = cursor.fetchone()[0]
            else:
                genre_id = genre_row[0]

            # Добавляем запись в соответствующую таблицу
            if selected_table == "Books":
                cursor.execute("INSERT INTO Books (title, date_of_publication, author_id, genre_id) VALUES (?, ?, ?, ?)", (title, date, author_id, genre_id))
            elif selected_table == "Authors":
                cursor.execute("INSERT INTO Authors (author_name, date_of_birth) VALUES (?, ?)", (author, date))
            elif selected_table == "Genres":
                cursor.execute("INSERT INTO Genres (genre_name) VALUES (?)", (genre,))

        # Обновляем таблицу
        self.load_data()

    def delete_entry(self):
        # Получаем выбранную таблицу
        selected_table = self.table_selector.get()
        selected_item = self.data_tree.focus()
        if selected_item:
            item_values = self.data_tree.item(selected_item)["values"]
            # Удаляем запись из базы данных
            with sqlite3.connect('library.db') as connection:
                cursor = connection.cursor()
                if selected_table == "Books":
                    book_title = item_values[0]
                    cursor.execute("DELETE FROM Books WHERE title=?", (book_title,))
                elif selected_table == "Authors":
                    author_name = item_values[0]
                    cursor.execute("DELETE FROM Authors WHERE author_name=?", (author_name,))
                elif selected_table == "Genres":
                    genre_name = item_values[0]
                    cursor.execute("DELETE FROM Genres WHERE genre_name=?", (genre_name,))
            # Обновляем таблицу
            self.load_data()

    def edit_entry(self):
        # Получаем выбранную запись
        selected_item = self.data_tree.focus()
        if selected_item:
            item_values = self.data_tree.item(selected_item)["values"]
            # Заполняем поля ввода значениями выбранной записи
            self.entry_title.delete(0, tk.END)
            self.entry_title.insert(0, item_values[0])

            date_parts = item_values[1].split("-")
            self.year_var.set(date_parts[0])
            self.month_combo.set(date_parts[1])
            self.day_combo.set(date_parts[2])

            self.entry_author.delete(0, tk.END)
            self.entry_author.insert(0, item_values[2])

            self.entry_genre.delete(0, tk.END)
            self.entry_genre.insert(0, item_values[3])

            # Меняем текст кнопки на "Сохранить"
            self.add_button.config(text="Сохранить", command=self.save_edit)

            # Сохраняем ID выбранной записи
            self.selected_item_id = item_values[4]

    def save_edit(self):
        # Получаем новые значения из полей ввода
        title = self.entry_title.get()
        day = self.day_var.get()
        month = self.month_var.get()
        year = self.year_var.get()
        author = self.entry_author.get()
        genre = self.entry_genre.get()

        # Форматируем дату
        date = f"{year}-{month}-{day}"

        # Получаем ID записи для редактирования
        selected_item_id = self.selected_item_id

        # Получаем выбранную таблицу
        selected_table = self.table_selector.get()

        # Подключаемся к базе данных
        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()

            # Проверяем, существует ли автор
            cursor.execute("SELECT author_id FROM Authors WHERE author_name=?", (author,))
            author_row = cursor.fetchone()

            # Если автора нет, добавляем его
            if not author_row:
                cursor.execute("INSERT INTO Authors (author_name, date_of_birth) VALUES (?, '')", (author,))
                cursor.execute("SELECT last_insert_rowid()")
                author_id = cursor.fetchone()[0]
            else:
                author_id = author_row[0]

            # Проверяем, существует ли жанр
            cursor.execute("SELECT genre_id FROM Genres WHERE genre_name=?", (genre,))
            genre_row = cursor.fetchone()

            # Если жанра нет, добавляем его
            if not genre_row:
                cursor.execute("INSERT INTO Genres (genre_name) VALUES (?)", (genre,))
                cursor.execute("SELECT last_insert_rowid()")
                genre_id = cursor.fetchone()[0]
            else:
                genre_id = genre_row[0]

            # Обновляем запись в соответствующей таблице
            if selected_table == "Books":
                cursor.execute("UPDATE Books SET title=?, date_of_publication=?, author_id=?, genre_id=? WHERE book_id=?", (title, date, author_id, genre_id, selected_item_id))
            elif selected_table == "Authors":
                cursor.execute("UPDATE Authors SET author_name=?, date_of_birth=? WHERE author_id=?", (author, date, selected_item_id))
            elif selected_table == "Genres":
                cursor.execute("UPDATE Genres SET genre_name=? WHERE genre_id=?", (genre, selected_item_id))

        # Обновляем таблицу
        self.load_data()

        # Меняем текст кнопки на "Добавить"
        self.add_button.config(text="Добавить", command=self.add_entry)

    def load_data(self):
        # Очищаем содержимое рамки
        for widget in self.data_frame.winfo_children():
            widget.destroy()

        # Получаем данные из выбранной таблицы
        selected_table = self.table_selector.get()
        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()

            if selected_table == "Books":
                cursor.execute('''SELECT Books.title, Books.date_of_publication, Authors.author_name, Genres.genre_name, Books.book_id
                                  FROM Books
                                  JOIN Authors ON Books.author_id = Authors.author_id
                                  JOIN Genres ON Books.genre_id = Genres.genre_id''')
            elif selected_table == "Authors":
                cursor.execute("SELECT * FROM Authors")
            elif selected_table == "Genres":
                cursor.execute("SELECT * FROM Genres")

            # Создаем древовидный виджет для отображения данных
            self.data_tree = ttk.Treeview(self.data_frame, columns=(1, 2, 3, 4), show="headings", selectmode="browse")
            self.data_tree.grid(row=0, column=0, sticky="nsew")

            # Создаем полосу прокрутки
            scrollbar = ttk.Scrollbar(self.data_frame, orient="vertical", command=self.data_tree.yview)
            scrollbar.grid(row=0, column=1, sticky="ns")
            self.data_tree.configure(yscrollcommand=scrollbar.set)

            # Создаем заголовки таблицы
            columns = [description[0] for description in cursor.description]
            for col_index, col_name in enumerate(columns):
                self.data_tree.heading(f"#{col_index}", text=col_name)

            # Выводим данные в таблицу
            for row_data in cursor.fetchall():
                self.data_tree.insert("", "end", values=row_data)

    def clear_and_restore_table(self):
        # Очищаем и восстанавливаем выбранную таблицу
        selected_table = self.table_selector.get()
        with sqlite3.connect('library.db') as connection:
            cursor = connection.cursor()
            if selected_table == "Books":
                cursor.execute("DELETE FROM Books")
                connection.commit()
            elif selected_table == "Authors":
                cursor.execute("DELETE FROM Authors")
                connection.commit()
            elif selected_table == "Genres":
                cursor.execute("DELETE FROM Genres")
                connection.commit()
        self.load_data()

def create_tables():
    # Создаем таблицы в базе данных
    with sqlite3.connect('library.db') as connection:
        cursor = connection.cursor()
        cursor.execute('''CREATE TABLE IF NOT EXISTS Books (
                            book_id INTEGER PRIMARY KEY,
                            title TEXT,
                            date_of_publication DATE,
                            author_id INTEGER,
                            genre_id INTEGER,
                            FOREIGN KEY (author_id) REFERENCES Authors(author_id),
                            FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
                        )''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS Authors (
                            author_id INTEGER PRIMARY KEY,
                            author_name TEXT,
                            date_of_birth DATE
                        )''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS Genres (
                            genre_id INTEGER PRIMARY KEY,
                            genre_name TEXT
                        )''')

if __name__ == "__main__":
    create_tables()
    root = tk.Tk()
    app = LibraryApp(root)
    root.mainloop()
