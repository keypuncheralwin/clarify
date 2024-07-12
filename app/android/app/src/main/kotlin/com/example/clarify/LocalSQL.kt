package com.example.clarify

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.util.Log

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_VERSION = 1
        private const val DATABASE_NAME = "UserHistory.db"
        private const val TABLE_NAME = "history"
        private const val COLUMN_ID = "id"
        private const val COLUMN_HISTORY_JSON = "history_json"
    }

    override fun onCreate(db: SQLiteDatabase) {
        val createTable = ("CREATE TABLE " + TABLE_NAME + "("
                + COLUMN_ID + " INTEGER PRIMARY KEY AUTOINCREMENT,"
                + COLUMN_HISTORY_JSON + " TEXT" + ")")
        db.execSQL(createTable)
        Log.d("DatabaseHelper", "Database created with table: $TABLE_NAME")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS $TABLE_NAME")
        onCreate(db)
        Log.d("DatabaseHelper", "Database upgraded from version $oldVersion to $newVersion")
    }

    fun insertHistory(historyJson: String) {
        val db = this.writableDatabase
        val contentValues = ContentValues()
        contentValues.put(COLUMN_HISTORY_JSON, historyJson)
        val rowId = db.insert(TABLE_NAME, null, contentValues)
        Log.d("DatabaseHelper", "Inserted row ID: $rowId")
        db.close()
    }
    

    fun getAllHistory(): List<String> {
        val historyList = mutableListOf<String>()
        val selectQuery = "SELECT * FROM $TABLE_NAME"
        val db = this.readableDatabase
        val cursor = db.rawQuery(selectQuery, null)
        if (cursor.moveToFirst()) {
            do {
                val historyJson = cursor.getString(cursor.getColumnIndex(COLUMN_HISTORY_JSON))
                Log.d("DatabaseHelper", "Retrieved history JSON: $historyJson")
                historyList.add(historyJson)
            } while (cursor.moveToNext())
        }
        cursor.close()
        db.close()
        return historyList
    }
    

    fun clearHistory() {
        val db = this.writableDatabase
        db.delete(TABLE_NAME, null, null)
        db.close()
    }
}
