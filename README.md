erDiagram
    Users ||--o{ DailyLogs : "1人のユーザーは複数の日次ログを持つ (has_many)"
    DailyLogs ||--o{ TemperatureLogs : "1日のログは複数の体温記録を持つ (has_many)"
    DailyLogs ||--o{ JointConditions : "1日のログは複数の部位状態を持つ (has_many)"
    DailyLogs ||--o{ MedicationLogs : "1日のログは複数の服薬記録を持つ (has_many)"

    Users {
        bigint id PK "主キー"
        string name "氏名"
        string email "メールアドレス (Unique)"
        string diagnosis_name "診断名 (例: SLE)"
        date started_at "治療開始日"
        datetime created_at
        datetime updated_at
    }

    DailyLogs {
        bigint id PK "主キー"
        bigint user_id FK "Usersテーブル参照 (Index)"
        date date "記録対象日 (UserごとUnique)"
        integer stiffness_duration "朝のこわばり(分)"
        integer pain_vas "痛み(0-100)"
        integer fatigue_vas "倦怠感(0-100)"
        text memo "自由記述メモ"
        datetime created_at
        datetime updated_at
    }

    TemperatureLogs {
        bigint id PK "主キー"
        bigint daily_log_id FK "DailyLogsテーブル参照 (Index)"
        datetime measured_at "計測時刻"
        float value "体温"
    }

    JointConditions {
        bigint id PK "主キー"
        bigint daily_log_id FK "DailyLogsテーブル参照 (Index)"
        string part_name "部位名 (例: left_wrist)"
        integer condition "状態 (0:無症状, 1:違和感, 2:痛み, 3:腫れ)"
    }

    MedicationLogs {
        bigint id PK "主キー"
        bigint daily_log_id FK "DailyLogsテーブル参照 (Index)"
        string medicine_name "薬名"
        float dosage "用量 (mgなど)"
        boolean is_taken "服用フラグ (T/F)"
    }