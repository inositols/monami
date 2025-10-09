{
  "indexes": [
    {
      "collectionGroup": "comments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "post_id",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "created_at",
          "order": "DESCENDING"
        },
        {
          "fieldPath": "__name__",
          "order": "DESCENDING"
        }
      ],
      "density": "SPARSE_ALL"
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "uid",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "created_at",
          "order": "DESCENDING"
        },
        {
          "fieldPath": "__name__",
          "order": "DESCENDING"
        }
      ],
      "density": "SPARSE_ALL"
    }
  ],
  "fieldOverrides": []
}