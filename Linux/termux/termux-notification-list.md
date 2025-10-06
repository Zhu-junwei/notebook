# termux-notification-list

```
termux-notification-list
```

过滤无用通知

```
termux-notification-list | jq '[.[] | select(.packageName | test("xiaomi|miui|milink") | not)]'
```

```
 termux-notification-list | jq 'map({id,tag,packageName})'
```

```
termux-notification-list | jq '[.[] | select(.packageName | test("xiaomi|miui|milink") | not) | {id,key,packageName,title,message:.content,when}]'
```

提取图标

```
unzip -p /data/app/~~iAhcQg8uUcepZATA31LLPw==/com.termux-eOi3gJd5dYvgsHdG9b0PqQ==/base.apk \
$(unzip -l /data/app/~~iAhcQg8uUcepZATA31LLPw==/com.termux-eOi3gJd5dYvgsHdG9b0PqQ==/base.apk | grep -i 'ic_launcher.png' | awk '{print $4}' | tail -n 1) \
> app_icon.png
```

