# Q008 答案解析

## 問題根因
PendingIntent 的 Parcelable 實現中，flags 在 writeToParcel 時寫入，
但在 createFromParcel 時沒有讀取。

## 涉及文件
1. `frameworks/base/core/java/android/app/PendingIntent.java`
2. `frameworks/base/services/core/java/com/android/server/am/PendingIntentRecord.java`
3. `frameworks/base/core/java/android/app/IActivityManager.aidl`

## Bug 分析

**文件 1：PendingIntent.java**
```java
@Override
public void writeToParcel(Parcel out, int flags) {
    out.writeStrongBinder(mTarget.asBinder());
    out.writeString(mCreatorPackage);
    out.writeInt(mRequestCode);
    out.writeInt(mFlags);  // flags 寫入了
}

public static final Creator<PendingIntent> CREATOR = new Creator<>() {
    @Override
    public PendingIntent createFromParcel(Parcel in) {
        IBinder target = in.readStrongBinder();
        String creatorPackage = in.readString();
        int requestCode = in.readInt();
        // BUG: 沒有讀取 flags！
        // int flags = in.readInt();
        
        return new PendingIntent(target, creatorPackage, requestCode, 0);  // flags=0
    }
};
```

**文件 2：PendingIntentRecord.java**
```java
void writeToParcel(Parcel out) {
    // BUG: 寫入順序和 PendingIntent.CREATOR 讀取順序不一致
    out.writeStrongBinder(this);
    out.writeString(key.packageName);
    out.writeInt(key.flags);  // flags 在這裡
    out.writeInt(key.requestCode);  // 順序對調了
}
```

**文件 3：IActivityManager.aidl**
```java
// AIDL 定義沒問題，但實現有問題
PendingIntent getIntentSender(int type, String packageName, 
    IBinder token, String resultWho, int requestCode, 
    in Intent[] intents, in String[] resolvedTypes, int flags);
```

## 修復方法
```java
// PendingIntent.java
public static final Creator<PendingIntent> CREATOR = new Creator<>() {
    @Override
    public PendingIntent createFromParcel(Parcel in) {
        IBinder target = in.readStrongBinder();
        String creatorPackage = in.readString();
        int requestCode = in.readInt();
        int flags = in.readInt();  // 讀取 flags
        
        return new PendingIntent(target, creatorPackage, requestCode, flags);
    }
};

// PendingIntentRecord.java
void writeToParcel(Parcel out) {
    out.writeStrongBinder(this);
    out.writeString(key.packageName);
    out.writeInt(key.requestCode);
    out.writeInt(key.flags);  // 統一順序
}
```

## 知識點
1. Parcelable 的讀寫順序必須一致
2. 多個類實現同一 Parcelable 時要協調
3. 跨 IPC 時要特別注意數據完整性
