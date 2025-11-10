# jq使用

格式化

```
jq . a.json
```

压缩

```
jq -c a.json
```

## 提取

提取单个字段的值

```
echo '{"name":"Alice","age":25}' | jq '.name'
# 输出："Alice"
```

提取嵌套字段

```
echo '{"user":{"name":"Bob","details":{"age":30}}}' | jq '.user.details.age'
# 输出：30
```

