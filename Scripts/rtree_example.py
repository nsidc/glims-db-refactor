hits = idx.intersection((0, 0, 10, 10), objects=True)

for i in hits:
    print("id, obj, bbox:  ", i.id, i.object, i.bbox)

id, obj, bbox:   45 None [0.9, 0.9, 2.0, 2.0]
id, obj, bbox:   46 89 [1.9, 1.9, 2.0, 2.0]
id, obj, bbox:   0 None [2.0, 2.0, 4.0, 4.0]
id, obj, bbox:   0 None [2.0, 2.0, 4.0, 4.0]
id, obj, bbox:   0 None [2.0, 2.0, 4.0, 9.0]

