## Miscellaneous notes

#### Docker can use up disk space

`docker system df`

/var/lib/docker/volumes# docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          53        7         14.42GB   13.53GB (93%)
Containers      24        0         298.4kB   298.4kB (100%)
Local Volumes   2804      1         870GB     869.8GB (99%)
Build Cache     112       0         9.282GB   9.282GB

Clean up:

`docker volume prune -f`

...
...
...
f8461f9a878da8cc08d141c9e9b523019eb465b28c25edaab006d356a14260c2
7c5103e92c173d905c21a2a074a8e069e6ea2d3ac4e9b15ca239e22789f2e8d0
d5e7294fa9ff24711776f2c53c613994b616ee06595fea684deccabba14d69e1
e345542e14ab9d599b3d5b37f3ab30caa06a61ed81ea33bf26fc270a06362a41
fe15e5ccfb99f6b5aaa6369f0d2d2b9ac1ac0f9406bd975a01daa98795d5fcf8
38eb48a87c183df0dc8d838f0cee25b676df15560ac7872bad475f6f6204eb23
73f5f1dc93f2d3a832cef81dd69710a44ffc680ced45bcffdaad591448564e50
98e726187b25fa85cd6d0c31c751c41f110da6c8d14019bfdc6e4e19ac0ec9a2
9c2ea6abb342e98a39786dc1c813755dbd7414ec81bee4b305f83f47d3873970

Total reclaimed space: 869.4GB