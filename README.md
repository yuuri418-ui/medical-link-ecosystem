erDiagram
    Users ||--o{ DailyLogs : "has many"
    DailyLogs ||--o{ TemperatureLogs : "has many"
    DailyLogs ||--o{ JointConditions : "has many"
    DailyLogs ||--o{ MedicationLogs : "has many"

    Users {
        bigint id PK
        string name "氏名"
        string email "メールアドレス"
        string diagnosis_name "診断名"
        date started_at "治療開始日"
        datetime created_at
        datetime updated_at
    }

    DailyLogs {
        bigint id PK
        bigint user_id FK "Users参照"
        date date "記録日"
        integer stiffness_duration "こわばり(分)"
        integer pain_vas "痛み(0-100)"
        integer fatigue_vas "倦怠感(0-100)"
        text memo "メモ"
        datetime created_at
        datetime updated_at
    }

    TemperatureLogs {
        bigint id PK
        bigint daily_log_id FK "DailyLogs参照"
        datetime measured_at "計測時刻"
        float value "体温"
    }

    JointConditions {
        bigint id PK
        bigint daily_log_id FK "DailyLogs参照"
        string part_name "部位(手首等)"
        integer condition "状態(0-3)"
    }

    MedicationLogs {
        bigint id PK
        bigint daily_log_id FK "DailyLogs参照"
        string medicine_name "薬名"
        float dosage "用量"
        boolean is_taken "服用フラグ"
    }