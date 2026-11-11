#set page("a4",
  flipped: true,
  columns: 3,
  margin: (x: 18pt, top: 25pt, bottom: 18pt),
  header-ascent: 35%,
  header: context text(font: "Noto Sans KR", size: 7pt)[
    전남대학교 / #text(weight: 600, size: 1.2em)[no sleep 0 guy]#super[박종현, 정영도, 최정환] #h(1fr)
    #counter(page).display("1 / 1", both: true)
  ],
)
#let serif = ("Noto Serif KR", )
#let sans = ("Noto Sans KR", )
#set text(font: serif, size: 8pt, top-edge: .8em, bottom-edge: .2em)
#set par(leading: .4em)
#set heading(numbering: none)
#show heading: set par(leading: .4em)
#show heading: set block(above: 0.5em, below: 0.5em)
#show raw.where(block: true): it => {
  block(width: 100%, breakable: true, below: 7pt, {
    set par(leading: .3em)
    let number-width = str(it.lines.len()).len() * .61em
    for line in it.lines {
      block(
        width: 100%,
        above: 0pt,
        below: 0pt,
        inset: (x: 1.5pt, y: 1pt),
        fill: if calc.even(line.number) { luma(92%) } else { luma(96%) },
        grid(
          columns: (number-width, 1fr),
          column-gutter: 3pt,
          align: (right + horizon, left + horizon),
          pdf.artifact(kind: "line-number", text(fill: luma(45%), str(line.number))),
          {
            // Allow long tokens to wrap without adding characters to copied text.
            show regex("[^ ]"): it => [#it#pdf.artifact(sym.zws)]
            box(width: 0pt, height: 1.2em, baseline: 0.2em) + line.body
          },
        ),
      )
    }
  })
}
#show raw: set text(font: ("DejaVu Sans Mono",) + sans, size: 6pt)


= 문자열
== 접미사 배열과 LCP 배열
```python
#접미사 배열과 lcp 배열
st = input()
n = len(st)
if n == 1:
  print(1)
  exit()
sa = list(range(n))
rank = [ord(i) for i in st]
tmp = [0]*n
o = 1
while o < n:
  f = lambda x:(rank[x],rank[x+o] if x+o<n else -1)
  sa.sort(key = f)
  tmp[sa[0]] = 0
  for i in range(1,n):
    tmp[sa[i]] = tmp[sa[i-1]]
    if f(sa[i]) != f(sa[i-1]):
      tmp[sa[i]] += 1
  rank[:] = tmp[:]
  o *= 2
for i in range(n-1):
  a = sa[i]
  b = sa[i+1]
lcp = [0]*n
h = 0
for i in range(n):
  if rank[i] == 0: continue
  a = sa[rank[i]]
  b = sa[rank[i]-1]
  while a+h<n and b+h<n and st[a+h]==st[b+h]:
    h += 1
  lcp[rank[i]] = h
  if h > 0:
    h -= 1
print(n*(n+1)//2 – sum(lcp))
```

== 매내쳐
```python
#매내쳐
d = input()
st = '#'
for i in d:
  st += i
  st += '#'
n = len(st)
a = [0]*n
r = 0
p = 0
for i in range(n):
  if i <= r:
    a[i] = min(a[2*p-i], r-i)
  
  idx1 = i-a[i]-1
  idx2 = i+a[i]+1
  while 0 <= idx1 and idx2 < n:
    if st[idx1] != st[idx2]: break
    a[i] += 1
    idx1 = i-a[i]-1
    idx2 = i+a[i]+1
  if r < i + a[i]:
    r = i + a[i]
    p = i
print(max(a))
```

== KMP
```python
#kmp
def pre():
  dp = [0]*m
  cur = 0
  for i in range(1,m):
    while cur and p[i] != p[cur]:
      cur = dp[cur-1]
    if p[i] == p[cur]:
      cur += 1
      dp[i] = cur
  return dp
t = input(); n = len(t)
p = input(); m = len(p)
pi = pre()
res = []
cur = 0
for i in range(n):
  while cur and t[i] != p[cur]:
    cur = pi[cur-1]
  if t[i] == p[cur]:
    if cur==m-1:
      res.append(i-m+2)
      cur = pi[cur]
    else:
      cur += 1
print(len(res))
if res:
  print(*res)
```

== 10억 근처 소수 (해싱)
```python
#10억 근처 소수(해싱)
948798427
979829143
1010899753
1021263161
1031639363
```

= 기하
== CCW (기본)
```python
#CCW(기본)
ccw = lambda a, b, c: (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1])
# ccw < 0 => 시계방향, ccw > 0 => 반시계방향
```

== 선분 교차
```python
#선분 교차
if ccw(a1, a2, b1) * ccw(a1, a2, b2) < 0 and ccw(b1, b2, a1) * ccw(b1, b2, a2) < 0:
# 참일 때 교차, 거짓일 때 교차하지 않음
```

== 볼록 껍질 (모노톤 체인)
```python
#볼록 껍질(모노톤 체인)
def convex_hull(lst):
  conv = []
  for c in lst:
    while len(conv) >= 2: # 끝점만 포함
      a, b = conv[-2], conv[-1]
      if ccw(a, b, c) >= 0:
        conv.pop()
      else:
        break
    conv.append(c)
  conv.pop()

  return conv

n = int(input())
lst = sorted([tuple(map(int, input().split())) for _ in range(n)])

res = []
res += convex_hull(lst)
lst.reverse()
res += convex_hull(lst)
print(len(res))
```

== 볼록 껍질 (그라함 스캔)
```python
#볼록 껍질(그라함 스캔)
n = int(input())
lst = [tuple(map(int, input().split())) for _ in range(n)]

res = 0
lst.sort()
convex = []
for c in lst:
  while len(convex) >= 2:
    a, b = convex[-2], convex[-1]
    if ccw(a, b, c) >= 0:
      convex.pop()
    else:
      break
  convex.append(c)
res += len(convex)

lst.reverse()
convex = []
for c in lst:
  while len(convex) >= 2:
    a, b = convex[-2], convex[-1]
    if ccw(a, b, c) >= 0:
      convex.pop()
    else:
      break
  convex.append(c)
res += len(convex)

print(res-2)
```

== 회전하는 캘리퍼스
CCW와 볼록 껍질 함수는 모노톤 체인 구현과 동일
```python
#회전하는 캘리퍼스
for t in range(int(input())):
  n = int(input())
  lst = sorted([tuple(map(int, input().split())) for _ in range(n)])

  res = []
  res += convex_hull(lst)
  res.pop()
  lst.reverse()
  res += convex_hull(lst)

  m, i, j, p, q = len(res), 0, 1, 0, 1
  for i in range(m-1):
    while j < m-1 and ccw(res[i], res[i+1], (res[j+1][0]-res[j][0]+res[i+1][0], res[j+1][1]-res[j][1]+res[i+1][1])) > 0:
      if dist(res[i], res[j]) > dist(res[p], res[q]):
        p, q = i, j
      j += 1
      if j == m-1:
        break
    if dist(res[i], res[j]) > dist(res[p], res[q]):
        p, q = i, j

  print(*res[p], *res[q])
```
원문 메모: 느리므로 C++로 옮겨서 구현.

= 자료구조
== 트라이
```cpp
//Trie
struct Trie
{
  Trie *next[10];
  bool end;
  Trie()
  {
    end = false;
    for(int i = 0; i<10; i++)
      next[i] = NULL;
  }
  ~Trie()
  {
    for(int i = 0; i<10; i++)
      delete next[i];
  }

  void insert(string &s)
  {
    Trie *cur = this;
    for(int i = 0; i<s.size(); i++)
    {
      int ind = s[i]-'0';
      if(!cur->next[ind])
        cur->next[ind] = new Trie();
      cur = cur->next[ind];
    }
    cur->end = true;
  }

  bool query(string &s)
  {
    Trie *cur = this;
    for(int i = 0; i<s.size(); i++)
    {
      int ind = s[i]-'0';
      if(!cur->next[ind])
        break;
      cur = cur->next[ind];
      if(i != s.size()-1 && cur->end)
        return false;
    }
    return true;
  }
};
```

== BIT
```cpp
//fenwick tree
class BIT
{
public:
  vector<long> tree;
  int n;
  void init(vector<long> arr)
  {
    n = arr.size()-1;
    tree.resize(n+1);
    for(int i = 1; i<=n; i++)
    {
      update(i,arr[i]);
    }
  }
  long sum(int index)
  {
    long res = 0;

    while(index > 0)
    {
      res+=tree[index];
      index -= (index & -index);
    }

    return res;
  }
  void update(int index, long val)
  {
    while(index <= n)
    {
      tree[index]+=val;
      index+=(index & -index);
    }
  }
};
```

== Lazy Segment Tree와 HLD
국제 메시 기구 문제의 쿼리:
- `1 X V`: X의 서브트리에 V를 더한다.
- `2 X Y V`: X부터 Y까지의 경로에 V를 더한다. 양 끝점 포함.
- `3 X V`: X의 서브트리에 V를 곱한다.
- `4 X Y V`: X부터 Y까지의 경로에 V를 곱한다. 양 끝점 포함.
- `5 X`: X의 서브트리 합을 출력한다.
- `6 X Y`: X부터 Y까지의 경로 합을 출력한다.
```cpp
//HLD
struct Node
{
  long value = 0;
};
struct Lazy
{
  long valueP = 0;
  long valueM = 1;
};
class LazySegTree
{
private:
  vector<Node> arr;
  vector<Node> tree;
  vector<Lazy> lazy;
  int n;
  Node trash = {0}; //의미없는 값 입력
  Node merge(Node a, Node b)
  {
    Node res;
    res.value = (a.value+b.value)%MOD;
    return res;
  }
  void lazyUpdate(int node, int start, int end)
  {
    if(lazy[node].valueM == 1 && lazy[node].valueP == 0)
      return;
    tree[node].value*=lazy[node].valueM;
    tree[node].value%=MOD;
    tree[node].value+=lazy[node].valueP * (end-start+1);
    tree[node].value%=MOD;

    if(start != end)
    {
      lazy[node*2].valueM*=lazy[node].valueM;
      lazy[node*2].valueM%=MOD;
      lazy[node*2].valueP*=lazy[node].valueM;
      lazy[node*2].valueP%=MOD;
      lazy[node*2].valueP+=lazy[node].valueP;
      lazy[node*2].valueP%=MOD;

      lazy[node*2+1].valueM*=lazy[node].valueM;
      lazy[node*2+1].valueM%=MOD;
      lazy[node*2+1].valueP*=lazy[node].valueM;
      lazy[node*2+1].valueP%=MOD;
      lazy[node*2+1].valueP+=lazy[node].valueP;
      lazy[node*2+1].valueP%=MOD;
    }
    lazy[node].valueM = 1;
    lazy[node].valueP = 0;
  }
  Node init(int node, int start, int end)
  {
    if(start == end)
      return tree[node] = arr[start];
    int mid = (start+end)/2;
    return tree[node] = merge(init(node*2,start,mid),init(node*2+1,mid+1,end));
  }
  Node query(int node, int start, int end, int left, int right)
  {
    lazyUpdate(node,start,end);
    if(start > right || end < left)
      return trash;
    if(start >= left && end <= right)
    {
      return tree[node];
    }
    
    int mid = (start+end)/2;
    return merge(query(node*2,start,mid,left,right),query(node*2+1,mid+1,end,left,right));
  }
  Node rangeUpdatePlus(int node, int start, int end, int left, int right, long l)
  {
    lazyUpdate(node,start,end);
    if(start > right || end < left)
      return tree[node];
    if(start >= left && end <= right)
    {
      lazy[node].valueP = l;
      lazyUpdate(node,start,end);
      return tree[node];
    }
    int mid = (start+end)/2;
    return tree[node] = merge(rangeUpdatePlus(node*2,start,mid,left,right,l),rangeUpdatePlus(node*2+1,mid+1,end,left,right,l));
  }
  Node rangeUpdateMul(int node, int start, int end, int left, int right, long l)
  {
    lazyUpdate(node,start,end);
    if(start > right || end < left)
      return tree[node];
    if(start >= left && end <= right)
    {
      lazy[node].valueM = l;
      lazyUpdate(node,start,end);
      return tree[node];
    }
    int mid = (start+end)/2;
    return tree[node] = merge(rangeUpdateMul(node*2,start,mid,left,right,l),rangeUpdateMul(node*2+1,mid+1,end,left,right,l));
  }
public:
  void init(int l)
  {
    n = l;
    arr = vector<Node>(n);
    tree = vector<Node>(4*n);
    lazy = vector<Lazy>(4*n);
  }
  void init(vector<Node> a)
  {
    n = a.size();
    arr = a;
    tree = vector<Node>(4*n);
    lazy = vector<Lazy>(4*n);
    init(1,0,n-1);
  }
  void init(vector<long> a)
  {
    n = a.size();
    arr = vector<Node>(n);
    for(int i = 0; i<n; i++)
      arr[i].value = a[i];
    tree = vector<Node>(4*n);
    lazy = vector<Lazy>(4*n);
    init(1,0,n-1);
  }
  long query(int left, int right)
  {
    if(left > right)
      swap(left,right);
    return query(1,0,n-1,left,right).value;
  }
  void updatePlus(int left, int right, long val)
  {
    if(left > right)
      swap(left,right);
    rangeUpdatePlus(1,0,n-1,left,right,val);
  }
  void updateMul(int left, int right, long val)
  {
    if(left > right)
      swap(left,right);
    rangeUpdateMul(1,0,n-1,left,right,val);
  }
};

int sz[MAX];
int depth[MAX];
int top[MAX];
int parent[MAX];
int in[MAX];
int out[MAX];
vector<int> graph[MAX];
vector<int> tempgraph[MAX];
vector<int> vis(MAX);
int id = 0;

void dfs(int x)
{
  vis[x] = true;

  for(int i = 0; i<tempgraph[x].size(); i++)
  {
    int y = tempgraph[x][i];
    if(vis[y])
      continue;
    vis[y] = true;
    graph[x].push_back(y);
    dfs(y);
  }
}
void dfs1(int x)
{
  sz[x] = 1;
  for(int i = 0; i<graph[x].size(); i++)
  {
    int y = graph[x][i];
    depth[y] = depth[x]+1;
    parent[y] = x;
    dfs1(y);
    sz[x]+=sz[y];
    if(sz[y] > sz[graph[x][0]])
      swap(graph[x][i],graph[x][0]);
  }
}
void dfs2(int x)
{
  in[x] = ++id;
  for(int i = 0; i<graph[x].size(); i++)
  {
    int y = graph[x][i];
    if(i == 0)
      top[y] = top[x];
    else
      top[y] = y;
    dfs2(y);
  }
  out[x] = id;
}
int main()
{
  ios_base::sync_with_stdio(0); 
  cin.tie(0);
  
  int n,q;
  cin >> n >> q;

  for(int i = 0; i<n-1; i++)
  {
    int a,b;
    cin >> a >> b;
    tempgraph[a].push_back(b);
    tempgraph[b].push_back(a);
  }
  top[1] = 1;
  dfs(1);
  dfs1(1);
  dfs2(1);
  LazySegTree seg;
  seg.init(n+1);
  while(q--)
  {
    long t,a,b,c;
    cin >> t >> a;
    if(t == 1)
    {
      cin >> b;
      seg.updatePlus(in[a],out[a],b);
    }
    if(t == 2)
    {
      cin >> b >> c;
      while(top[a] != top[b])
      {
        if(depth[top[a]] < depth[top[b]])
          swap(a,b);
        int tp = top[a];
        seg.updatePlus(in[tp],in[a],c);
        a = parent[tp];
      }
      seg.updatePlus(in[a],in[b],c);
    }
    if(t == 3)
    {
      cin >> b;
      seg.updateMul(in[a],out[a],b);
    }
    if(t == 4)
    {
      cin >> b >> c;
      while(top[a] != top[b])
      {
        if(depth[top[a]] < depth[top[b]])
          swap(a,b);
        int tp = top[a];
        seg.updateMul(in[tp],in[a],c);
        a = parent[tp];
      }
      seg.updateMul(in[a],in[b],c);
    }
    if(t == 5)
    {
      cout << seg.query(in[a],out[a]) << "\n"; 
    }
    if(t == 6)
    {
      cin >> b;
      long hap = 0;
      while(top[a] != top[b])
      {
        if(depth[top[a]] < depth[top[b]])
          swap(a,b);
        int tp = top[a];
        hap += seg.query(in[tp],in[a]);
        hap%=MOD;
        a = parent[tp];
      }
      hap+=seg.query(in[a],in[b]);
      hap%=MOD;
      cout << hap << "\n";
    }
  }
  return 0;
}
```

== Undo Union-Find와 오프라인 동적 연결성
그래프와 쿼리 문제:
- `1 A B`: 없는 간선 A-B를 추가한다.
- `2 A B`: 존재하는 간선 A-B를 제거한다.
- `3 A B`: A에서 B로 가는 경로가 있으면 1, 없으면 0을 출력한다.
```cpp
//UnionFind
class UnionFind
{
public:
  stack<pair<int,int>> stk;
  vector<int> parent;
  vector<int> cnt;
  void init(int size)
  {
    parent.resize(size);
    cnt.resize(size);
    for(int i = 0; i<size; i++)
    {
      parent[i] = i;
      cnt[i] = 1;
    }
  }
  int find(int x)
  {
    if(parent[x] == x)
      return x;
    return find(parent[x]);
  }
  bool merge(int x, int y)
  {
    x = find(x);
    y = find(y);
    if(x == y)
      return 0;

    if(cnt[x] < cnt[y])
      swap(x,y);
    if(cnt[x] == cnt[y])
      cnt[x]++;
    parent[y] = x;
    stk.push({x,y});
    return 1;
  }
  bool isUnion(int x, int y)
  {
    x = find(x);
    y = find(y);
    if(x == y)
      return true;
    return false;
  }

  void undo(int t)
  {
    while(t--)
    {
      int x = stk.top().first;
      int y = stk.top().second;
      stk.pop();
      parent[y] = y;

      if(cnt[x] == cnt[y]+1)
        cnt[x]--;
    }
  }
};
vector<pair<int,int>> query(MAX);
vector<pair<int,int>> tree[4*MAX];
UnionFind uf;
void update(int node, int start, int end, int left,int right, pair<int,int> & edge)
{
  if(left > end || right < start)
    return;
  if(left <= start && right >= end)
  {
    tree[node].push_back(edge);
    return;
  }
  int mid = (start+end)/2;
  update(node*2,start,mid,left,right,edge);
  update(node*2+1,mid+1,end,left,right,edge);
}

void dfs(int node, int start, int end)
{
  int cnt = 0;
  for(int i = 0; i<tree[node].size(); i++)
    cnt+=uf.merge(tree[node][i].first, tree[node][i].second);


  if(start == end)
  {
    cout << uf.isUnion(query[start].first,query[start].second) << "\n";
    uf.undo(cnt);
    return;
  }

  int mid = (start+end)/2;
  dfs(node*2,start,mid);
  dfs(node*2+1,mid+1,end);
  uf.undo(cnt);
}

int main()
{
  ios_base::sync_with_stdio(0); 
  cin.tie(0);

  int n,m;
  cin >> n >> m;

  int index = 0;
  map<pair<int,int>,int> mp;
  vector<int> st(m);
  vector<pair<pair<int,int>,pair<int,int>>> edge;
  for(int i = 0; i<m; i++)
  {
    int t,a,b;
    cin >> t >> a >> b;

    if(a > b)
      swap(a,b);

    if(t == 1)
    {
      mp[{a,b}] = index;
    }
    if(t == 2)
    {
      int s = mp[{a,b}];
      int e = index-1;
      if(s <= e)
        edge.push_back({{s,e},{a,b}});
      mp.erase({a,b});
    }
    if(t == 3)
    {
      query[index] = {a,b};
      index++;
    }
  }
  uf.init(MAX);
  for(auto i : mp)
  {
    if(i.second <= index-1)
      edge.push_back({{i.second,index-1},i.first});
  }

  for(int i = 0; i<edge.size(); i++)
  {
    update(1,0,index-1,edge[i].first.first,edge[i].first.second,edge[i].second);
  }

  dfs(1,0,index-1);

  return 0;
}
```

== 구간 최솟값
```cpp
int n,l;
cin >> n >> l;

vector<int> arr(n);

for(int i = 0; i<n; i++)
  cin >> arr[i];

deque<pair<int,int>> dq;

priority_queue<pair<int,int>> pq;

for(int i = 0; i<n; i++)
{
  while(!pq.empty())
  {
    if(pq.top().second+l <= i)
      pq.pop();
    else
      break;
  }
  pq.push({-arr[i],i});
  cout << -pq.top().first << " ";
}
```

== Auxiliary Tree
```cpp
#define N 100000
#define NL 18
 
int fs[N], ls[N];
int depth[N];
int st[NL][3*N], lg[3*N];
 
int cur;
vector<int> g[N];
vector<int> g0[N];
 
void ett_dfs(int v, int p, int d) {
  st[0][fs[v] = cur++] = v;
  depth[v] = d;
  for(int w : g[v]) {
  if(w == p) continue;
  ett_dfs(w, v, d+1);
  st[0][cur++] = v;
  }
  ls[v] = cur-1;
}
 
void construct() {
  cur = 0;
  // Euler tour technique
  ett_dfs(0, -1, 0);
  lg[0] = lg[1] = 0;
  for(int i=2; i<=cur; ++i) lg[i] = lg[i >> 1] + 1;
 
  // Sparse Table
  for(int i=0, b=1; i<lg[cur]; ++i, b<<=1) {
  for(int j=0; j<(cur - (b<<1) + 1); ++j) {
    st[i+1][j] = (depth[st[i][j]] <= depth[st[i][j+b]] ? st[i][j] : st[i][j+b]);
  }
  }
}
 
bool cmp_at(int x, int y) {
  return fs[x] < fs[y];
}
 
inline int lca(int u, int v) {
  int x = fs[u], y = fs[v];
  if(x > y) swap(x, y);
  int l = lg[y - x + 1];
  return (depth[st[l][x]] <= depth[st[l][y - (1 << l) + 1]] ? st[l][x] : st[l][y - (1 << l) + 1]);
}

// 정점 vs를 포함하는 Auxiliary Tree를 구축한다.
// 결과는 g0에 저장된다.
// 반환값은 Auxiliary Tree의 루트 정점이다.
int stk[2*N];
inline int auxiliary_tree(vector<int> &vs, vector<int> g0[N]) {
  sort(vs.begin(), vs.end(), cmp_at);
  int k = vs.size();
  for(int i=0; i<k-1; ++i) {
  vs.push_back(lca(vs[i], vs[i+1]));
  }
  sort(vs.begin(), vs.end(), cmp_at);
  int prv = -1;
  int cur = 0;
  for(int i=0; i<vs.size(); ++i) {
  int v = vs[i];
  if(prv == v) continue;
  while(cur > 0 && ls[stk[cur-1]] < fs[v]) --cur;
  if(cur > 0) {
    g0[stk[cur-1]].push_back(v);
  }
  g0[v].clear();
  stk[cur++] = v;
  prv = v;
  }
  return stk[0];
}
```

= 그래프
== SCC
```cpp
//scc
int id,sccIndex;
int d[MAX];
int sccNum[MAX];
bool finish[MAX];
vector<vector<int>> scc;
stack<int> stk;
vector<int> graph[MAX];
int Scc(int x)
{
  d[x] = ++id;
  stk.push(x);

  int result = d[x];
  for(int i : graph[x])
  {
    if(d[i] == 0)
      result = min(result, Scc(i));
    else if(!finish[i])
      result = min(result, d[i]);
  }

  if(result == d[x])
  {
    vector<int> s;

    while(true)
    {
      int a = stk.top();
      stk.pop();
      s.push_back(a);
      finish[a] = true;
      sccNum[a] = sccIndex;
      if(a == x)
        break;
    }
    sort(all(s));
    scc.push_back(s);
    sccIndex++;
  }
  return result;
}
```

== 단절점과 단절선
=== 단절점
```cpp
//단절점
int n, m, disc[MAX_N + 1], cut[MAX_N + 1], ans, d, a, b;
vector<vector<int>> vt;

int dfs(int here, bool r) {
  disc[here] = ++d;
  int ret = disc[here];
  int child = 0;
  for (int there : vt[here]) {
    if (!disc[there]) {
      child++;
      int df = dfs(there, 0);
      if (!r&&df >= disc[here]) 
        cut[here] = true;
      ret = min(ret, df);
    }
    else
      ret = min(ret, disc[there]);
  }
  if (r&&child > 1) 
    cut[here] = true;
  return ret;
}
int main() {
  scanf("%d%d", &n, &m);
  vt.resize(n + 1);
  for (int i = 0; i < m; i++) {
    scanf("%d%d", &a, &b);
    vt[a].push_back(b);
    vt[b].push_back(a);
  }
  for (int i = 1; i <= n; i++)
    if (!disc[i])
      dfs(i, 1);
  for (int i = 1; i <= n; i++)
    if (cut[i])
      ans++;
  printf("%d\n", ans);
  for (int i = 1; i <= n; i++)
    if (cut[i])
      printf("%d ", i);
  return 0;
}
```

=== 단절선
```cpp
//단절선
int n, m, disc[MAX_N + 1], cut[MAX_N + 1], d, a, b;
vector<vector<int>> vt;
vector<pair<int, int>> res;
int dfs(int here, int par) {
  disc[here] = ++d;
  int ret = disc[here];
  int child = 0;
  for (int there : vt[here]) {
    if (there == par)
      continue;
    if (!disc[there]) {
      int df = dfs(there, here);
      if (df > disc[here])
        res.push_back({ min(here,there),max(here,there) });
      ret = min(ret, df);
    }
    else
      ret = min(ret, disc[there]);
  }
  return ret;
}
int main() {
  scanf("%d%d", &n, &m);
  vt.resize(n + 1);
  for (int i = 0; i < m; i++) {
    scanf("%d%d", &a, &b);
    vt[a].push_back(b);
    vt[b].push_back(a);
  }
  for (int i = 1; i <= n; i++)
    if (!disc[i])
      dfs(i, 0);
  sort(res.begin(), res.end());
  printf("%d\n", res.size());
  for (auto x : res)
    printf("%d %d\n", x.first, x.second);
  return 0;
}
```

== 이분 매칭
=== DFS 기반 매칭
```cpp
//O(VE)
int n, m;
vector <int> graph[1001];
 
int match[1001];
// 현재 각 일에 매칭된 직원 번호
 
int cache[1001];
bool DFS(int v)
{
  cache[v] = 1;
  for (int nv : graph[v])
  {
    if (cache[match[nv]]) continue;
    if (match[nv] == 0 || DFS(match[nv]))
    {
      // 증가 경로를 찾았다.
      match[nv] = v;
      return true;
    }
  }
 
  return false;
}
 
int main()
{
  ios::sync_with_stdio(0);
  cin.tie(0), cout.tie(0);
 
  cin >> n >> m;
  for (int a = 1; a <= n; a++)
  {
    int sz; cin >> sz;
    for (int i = 0; i < sz; i++)
    {
      int b; cin >> b;
      graph[a].push_back(b);
    }
  }
 
  int ans = 0;
  for (int a = 1; a <= n; a++)
  {
    memset(cache, 0, sizeof cache);
    if (DFS(a)) ans++;
  }
 
  cout << ans;
}
```

=== BFS 레벨 기반 매칭
```cpp
//O(root(V)E)
int n, m;
vector <int> graph[1001];
 
int mA[1001], mB[1001];
int dist[1001];
 
void BFS()
{
  memset(dist, -1, sizeof dist);
  queue <int> q;
  for (int i = 1; i <= n; i++)
  {
    if (mA[i]) continue;
    q.push(i);
    dist[i] = 0;
  }
 
  while (!q.empty())
  {
    int v = q.front(); q.pop();
    for (int nv : graph[v])
    {
      if (!mB[nv]) continue;
      if (dist[mB[nv]] != -1) continue;
      dist[mB[nv]] = dist[v] + 1;
      q.push(mB[nv]);
    }
  }
}
 
bool DFS(int v)
{
  for (int nv : graph[v])
  {
    if (!mB[nv] || dist[v] + 1 == dist[mB[nv]] && DFS(mB[nv]))
    {
      // 증가 경로를 찾았다.
      mA[v] = nv;
      mB[nv] = v;
      return true;
    }
  }
  return false;
}
 
int main()
{
  ios::sync_with_stdio(0);
  cin.tie(0), cout.tie(0);
 
  cin >> n >> m;
  for (int a = 1; a <= n; a++)
  {
    int sz; cin >> sz;
    for (int i = 0; i < sz; i++)
    {
      int b; cin >> b;
      graph[a].push_back(b);
    }
  }
 
  int ans = 0;
  while (true)
  {
    BFS();
 
    int res = 0;
    for (int i = 1; i <= n; i++)
    {
      if (mA[i]) continue;
      if (DFS(i)) res++;
    }
 
    if (!res) break;
    ans += res;
  }
 
  cout << ans;
}
```

== 최대 유량 (디닉)과 MCMF
=== 디닉
```cpp
//dinic use adj list
struct Edge
{
  int v;
  long cap;
  int rev;
};
class Dinic
{
public:
  vector<vector<Edge>> graph;
  vector<int> level, work;
  int S,E;
  void init(int mx, int s, int e)
  {
    graph.resize(mx+1);
    level.resize(mx+1);
    work.resize(mx+1);
    S = s;
    E = e;
  }

  void addEdge(int u, int v, long cap, bool p = false)
  {
    graph[u].push_back({v,cap,(int)graph[v].size()});
    graph[v].push_back({u,p ? cap : 0,(int)graph[u].size()-1});
  }
  void BFS(int s)
  {
    fill(all(level),-1);
    queue<int> q;
    q.push(s);
    level[s] = 0;
    while(!q.empty())
    {
      int x = q.front();
      q.pop();
      for(auto i : graph[x])
      {
        int y = i.v;
        long cap = i.cap;
        if(level[y] == -1 && cap > 0)
        {
          q.push(y);
          level[y] = level[x]+1;
        }
      }
    }
  }

  long DFS(int x, long flow)
  {
    if(x == E)
      return flow;

    for(int &i =work[x]; i<graph[x].size(); i++)
    {
      int y = graph[x][i].v;
      long cap = graph[x][i].cap;
      int rev = graph[x][i].rev;
      if(level[x]+1 == level[y] && cap > 0)
      {
        long p = DFS(y,min(flow,cap));
        if(p > 0)
        {
          graph[x][i].cap-=p;
          graph[y][rev].cap+=p;
          return p;
        }
      }
    }
    return 0;
  }

  long maxFlow(int s, int e)
  {
    long res = 0;
    while(true)
    {
      BFS(s);
      if(level[e] == -1)
        break;
      fill(all(work),0);
      while(true)
      {
        long p = DFS(s,LNF);
        if(!p)
          break;
        res+=p;
      }
    }
    return res;
  }
};

```

=== MCMF
```cpp
//MCMF
vector<pair<int,int>> graph[MAX];
int f[MAX][MAX],c[MAX][MAX],d[MAX],cost[MAX][MAX];
long dis[MAX];
int n,m;
void SPFA(int s)
{
  queue<int> q;
  vector<bool> inQ(MAX,0);
  q.push(s);
  dis[s] = 0;

  while(!q.empty())
  {
    int x = q.front();
    q.pop();
    inQ[x] = false;

    for(int i = 0; i<graph[x].size(); i++)
    {
      int y = graph[x][i].first;
      int z = graph[x][i].second;

      if(c[x][y]-f[x][y] > 0 && dis[x]+z < dis[y])
      {
        dis[y] = dis[x]+z;
        d[y] = x;
        if(!inQ[y])
        {
          inQ[y] = true;
          q.push(y);
        }
      }
      
    }
  }
}
int main()
{
  ios_base::sync_with_stdio(0); 
  cin.tie(0);
  
  int n,m;
  cin >> n >> m;
  for(int i = 1; i<=n; i++)
  {
    graph[0].push_back({i,0});
    graph[i].push_back({0,0});
    c[0][i] = 1;
    int l;
    cin >> l;
    for(int j = 0; j<l; j++)
    {
      int a,b;
      cin >> a >> b;
      a+=n;
      graph[i].push_back({a,b});
      graph[a].push_back({i,-b});
      cost[i][a] = b;
      cost[a][i] = -b;
      c[i][a] = 1;
    }
  }

  for(int i = 1; i<=m; i++)
  {
    graph[n+i].push_back({n+m+1,0});
    graph[n+m+1].push_back({n+i,0});
    c[n+i][n+m+1] = 1;
  }
  int s = 0,e = n+m+1;
  long res = 0,v = 0;
  while(true)
  {
    fill(d,d+MAX,-1);
    fill(dis,dis+MAX,INF);
    SPFA(s);

    if(d[e] == -1)
      break;
    int mn = INF;
    for(int i = e; i!=s; i=d[i])
      mn = min(mn,c[d[i]][i]-f[d[i]][i]);
    for(int i = e; i!=s; i=d[i])
    {
      v+=mn*cost[d[i]][i];
      f[d[i]][i]+=mn;
      f[i][d[i]]-=mn;
    }
    res+=mn;
  }
  cout << res << "\n" << v << endl;
  return 0;
}
```

== BCC
```cpp
int v, e;
vector <int> graph[SIZE];
 
vector<vector<pii> > BCC;
 
int DFS_cnt = 1;
int DFS_num[SIZE];
int DFS_min[SIZE];
 
vector<pii> stk;
 
void DFS(int v, int p)
{
  DFS_num[v] = DFS_min[v] = DFS_cnt++;
  for (int nv : graph[v])
  {
    if (nv == p) continue;
    if (DFS_num[v] > DFS_num[nv]) stk.push_back({ v, nv });
    // 아직 방문하지 않은 간선을 스택에 넣는다.
 
    if (DFS_num[nv])
    {
      // 역방향 간선
      DFS_min[v] = min(DFS_min[v], DFS_num[nv]);
    }
    else
    {
      // 순방향 간선
      DFS(nv, v);
      DFS_min[v] = min(DFS_min[v], DFS_min[nv]);
      if (DFS_min[nv] >= DFS_num[v])
      {
        BCC.emplace_back();
        while (true)
        {
          pii e = stk.back(); stk.pop_back();
          BCC.back().push_back(e);
 
          if (e == pii(v, nv)) break;
        }
      }
    }
  }
}
 
int main()
{
  ios::sync_with_stdio(0);
  cin.tie(0), cout.tie(0);
 
  cin >> v >> e;
  for (int i = 0; i < e; i++)
  {
    int a, b; cin >> a >> b;
    graph[a].push_back(b);
    graph[b].push_back(a);
  }
 
  for (int i = 1; i <= v; i++)
  {
    if (!DFS_num[i]) DFS(i, 0);
  }
 
  cout << BCC.size() << '\n';
  for (auto& it : BCC)
  {
    for (pii e : it) cout << "(" << e.first << "," << e.second << ") ";
    cout << "\n";
  }
}
```

== LCA
```cpp
vector<int> graph[MAX];

int parent[MAX];
int depth[MAX];
int st[MAXL][MAX];
int n;
void dfs(int x, int par,int d)
{
  depth[x] = d;
  parent[x] = par;
  for(int y : graph[x])
  {
    if(y != par)
      dfs(y,x,d+1);
  }
}
void construct()
{
  dfs(1,0,0);

  for(int i = 1; i<=n; i++)
    st[0][i] =  parent[i];
  
  for(int i = 1; i<MAXL; i++)
  {
    for(int j = 1; j<=n; j++)
      st[i][j] = st[i-1][st[i-1][j]];
  }
}

int LCA(int x, int y)
{
  if(depth[x] > depth[y])
    swap(x,y);

  for(int i = 0; i<MAXL; i++)
  {
    if((depth[y]-depth[x])&(1<<i))
      y = st[i][y];
  }

  if(x == y)
    return x;
  for(int i = MAXL-1; i>=0; i--)
  {
    if(st[i][x] != st[i][y])
    {
      x = st[i][x];
      y = st[i][y];
    }
  }
  return st[0][x];
}
```

== 센트로이드 분할
N개의 정점으로 구성된 가중치 없는 트리가 주어진다. 트리 상의 두 정점 사이의 거리는 두 정점 사이의 간선의 개수로 정의한다.
각 정점에는 수가 적혀 있으며, 적어도 두 정점은 같은 값임이 보장된다. 이때, 서로 같은 값이 쓰여 있는 두 정점 쌍 중 가장 거리가 가까울 때의 거리를 구해보자.
```cpp
int n;
int c[N];
 
vector <int> graph[N];
 
int sz[N];
int cache[N];
 
void getSz(int v, int p)
{
  sz[v] = 1;
  for (int nv : graph[v])
  {
    if (nv == p) continue;
    if (cache[nv]) continue;
 
    getSz(nv, v);
    sz[v] += sz[nv];
  }
}
 
int getCent(int v, int p, int csz)
{
  for (int nv : graph[v])
  {
    if (nv == p) continue;
    if (cache[nv]) continue;
    if (sz[nv] > csz / 2) return getCent(nv, v, csz);
  }
 
  return v;
}
 
void DFS(int v, int p, int l, map <int, int> &nd)
{
  if (nd.find(c[v]) == nd.end()) nd[c[v]] = l;
  else nd[c[v]] = min(nd[c[v]], l);
 
  for (int nv : graph[v])
  {
    if (nv == p) continue;
    if (cache[nv]) continue;
    DFS(nv, v, l + 1, nd);
  }
}
 
int solve(int v)
{
  getSz(v, 0);
  int csz = sz[v];
  int cent = getCent(v, 0, csz);
 
  cache[cent] = 1;
 
  map <int, int> d;
  d[c[cent]] = 0;
 
  int ans = INF;
  for (int nv : graph[cent])
  {
    if (cache[nv]) continue;
 
    map <int, int> nd;
    DFS(nv, cent, 1, nd);
 
    for (auto it : nd)
    {
      int num = it.first;
      int len = it.second;
 
      if (d.find(num) == d.end()) continue;
      int res = len + d[num];
      ans = min(ans, res);
    }
 
    for (auto it : nd)
    {
      int num = it.first;
      int len = it.second;
 
      if (d.find(num) == d.end()) d[num] = len;
      else d[num] = min(d[num], len);
    }
  }
 
  for (int nv : graph[cent])
  {
    if (cache[nv]) continue;
 
    int res = solve(nv);
    ans = min(ans, res);
  }
 
  return ans;
}
 
int main()
{
  ios::sync_with_stdio(0);
  cin.tie(0), cout.tie(0);
 
  cin >> n;
  for (int i = 1; i <= n; i++) cin >> c[i];
 
  for (int i = 0; i < n - 1; i++)
  {
    int u, v; cin >> u >> v;
    graph[u].push_back(v);
    graph[v].push_back(u);
  }
 
  cout << solve(1);
}
```

= PBDS
== Ordered Set
`order_of_key(NUM)`: NUM보다 작은 원소의 개수.
`find_by_order(K)`: 0-indexed K번째 원소의 iterator.
```cpp
//pbds ordered_set
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>
using namespace __gnu_pbds;
#define ordered_set tree<int, null_type, less<int>, rb_tree_tag,tree_order_statistics_node_update>

ordered_set OS;
OS.insert(1);
OS.order_of_key(10)
*(OS.find_by_order(0))
OS.erase(1)
```

== Multiset
```cpp
//multiset
#include <ext/pb_ds/assoc_container.hpp>
#include <ext/pb_ds/tree_policy.hpp>
using namespace __gnu_pbds;
#define ordered_set tree<int, null_type, less_equal<int>, rb_tree_tag,tree_order_statistics_node_update>

void m_erase(ordered_set &OS, int val){
  int index = OS.order_of_key(val);
  ordered_set::iterator it = OS.find_by_order(index);
  if(*it == val) OS.erase(it);
}
```

= 추가 템플릿 공통 설정
이하 코드는 C++17 기준. 각 코드 블록은 공통 설정과 함께 사용한다.
정점과 배열은 별도 표기가 없으면 0-indexed이다.
거리·합·곱의 범위가 자료형을 넘지 않는지 확인한다.
```cpp
#include <algorithm>
#include <array>
#include <cassert>
#include <deque>
#include <functional>
#include <limits>
#include <numeric>
#include <queue>
#include <string>
#include <tuple>
#include <utility>
#include <vector>
using namespace std;
using ll = long long;
using i128 = __int128_t;
constexpr ll INF64 = (1LL << 62);
```

= 그래프 보충
== DSU와 크루스칼 MST
경로 압축 + 크기 기준 병합. DSU 연산은 분할 상환 $O(alpha(N))$,
MST는 $O(E log E)$. 반환값은 (최소 신장 숲 비용, 선택 간선 수).
정점이 1개 이상일 때 선택 간선 수가 $N - 1$이면 연결 그래프이다.
```cpp
struct DSU {
  vector<int> p, sz;
  DSU(int n) : p(n), sz(n, 1) {
    iota(p.begin(), p.end(), 0);
  }
  int find(int x) {
    return p[x] == x ? x : p[x] = find(p[x]);
  }
  bool unite(int a, int b) {
    a = find(a); b = find(b);
    if (a == b) return false;
    if (sz[a] < sz[b]) swap(a, b);
    p[b] = a; sz[a] += sz[b];
    return true;
  }
};
struct MstEdge { int u, v; ll w; };
pair<ll, int> kruskal(int n, vector<MstEdge> e) {
  sort(e.begin(), e.end(), [](auto a, auto b) {
    return a.w < b.w;
  });
  DSU uf(n);
  ll cost = 0;
  int used = 0;
  for (auto [u, v, w] : e) {
    if (uf.unite(u, v)) {
      cost += w;
      ++used;
    }
  }
  return {cost, used};
}
```

== 다익스트라
음수 간선 불가. 인접 리스트 `g[u] = {(v, w), ...}`.
$O((V + E) log V)$. 유한 거리와 거리 + 간선 비용은 `INF64` 미만이어야 한다.
도달 불가는 `INF64`.
```cpp
vector<ll> dijkstra(
  const vector<vector<pair<int, ll>>>& g, int s
) {
  vector<ll> d(g.size(), INF64);
  using P = pair<ll, int>;
  priority_queue<P, vector<P>, greater<P>> pq;
  d[s] = 0; pq.push({0, s});
  while (!pq.empty()) {
    auto [du, u] = pq.top(); pq.pop();
    if (du != d[u]) continue;
    for (auto [v, w] : g[u]) {
      if (du + w < d[v]) {
        d[v] = du + w;
        pq.push({d[v], v});
      }
    }
  }
  return d;
}
```

== 0-1 BFS
모든 간선 비용이 0 또는 1인 경우 $O(V + E)$ 최단 경로.
```cpp
vector<ll> bfs01(
  const vector<vector<pair<int, int>>>& g, int s
) {
  vector<ll> d(g.size(), INF64);
  deque<pair<ll, int>> q;
  d[s] = 0; q.push_front({0, s});
  while (!q.empty()) {
    auto [du, u] = q.front(); q.pop_front();
    if (du != d[u]) continue;
    for (auto [v, w] : g[u]) {
      if (du + w >= d[v]) continue;
      d[v] = du + w;
      if (w == 0) q.push_front({d[v], v});
      else q.push_back({d[v], v});
    }
  }
  return d;
}
```

== 플로이드 워셜
$O(V^3)$ 시간, $O(V^2)$ 공간. 행렬 초기값은 `INF64`, 대각선은 0,
평행 간선은 최소 비용을 저장한다. 음수 간선 허용.
음수 사이클이 없고 모든 유한 경로 비용의 절댓값이 `INF64` 미만인 경우 사용.
```cpp
void floyd(vector<vector<ll>>& d) {
  int n = d.size();
  for (int k = 0; k < n; ++k)
    for (int i = 0; i < n; ++i) {
      if (d[i][k] == INF64) continue;
      for (int j = 0; j < n; ++j) {
        if (d[k][j] == INF64) continue;
        d[i][j] = min(d[i][j],
                d[i][k] + d[k][j]);
      }
    }
}
```

== 위상 정렬 (Kahn)
방향 그래프, $O(V + E)$. 결과 크기가 $V$ 미만이면 사이클 존재.
사전순 최소 순서가 필요하면 큐 대신 최소 힙을 사용한다.
```cpp
vector<int> topo(const vector<vector<int>>& g) {
  int n = g.size();
  vector<int> indeg(n), order;
  for (auto& adj : g)
    for (int v : adj) ++indeg[v];
  queue<int> q;
  for (int i = 0; i < n; ++i)
    if (!indeg[i]) q.push(i);
  while (!q.empty()) {
    int u = q.front(); q.pop();
    order.push_back(u);
    for (int v : g[u])
      if (--indeg[v] == 0) q.push(v);
  }
  return order;
}
```

== 2-SAT (Kosaraju)
$O(V + E)$. 변수 $i$의 양의 리터럴은 `2*i`, 부정은 `2*i+1`.
`add_or(a, b)`는 두 리터럴의 OR 절, 참 강제는 `add_or(a, a)`.
`solve()`가 참이면 `value[i]`가 해이다. 재귀 DFS이므로 깊이 제한에 주의.
```cpp
struct TwoSAT {
  int n;
  vector<vector<int>> g, rg;
  vector<int> seen, order, comp, value;
  TwoSAT(int n) : n(n), g(2*n), rg(2*n) {}
  void edge(int a, int b) {
    g[a].push_back(b); rg[b].push_back(a);
  }
  void add_or(int a, int b) {
    edge(a ^ 1, b); edge(b ^ 1, a);
  }
  void dfs1(int u) {
    seen[u] = 1;
    for (int v : g[u])
      if (!seen[v]) dfs1(v);
    order.push_back(u);
  }
  void dfs2(int u, int c) {
    comp[u] = c;
    for (int v : rg[u])
      if (comp[v] == -1) dfs2(v, c);
  }
  bool solve() {
    seen.assign(2*n, 0); order.clear();
    comp.assign(2*n, -1); value.assign(n, 0);
    for (int i = 0; i < 2*n; ++i)
      if (!seen[i]) dfs1(i);
    reverse(order.begin(), order.end());
    int c = 0;
    for (int u : order)
      if (comp[u] == -1) dfs2(u, c++);
    for (int i = 0; i < n; ++i) {
      if (comp[2*i] == comp[2*i+1])
        return false;
      value[i] = comp[2*i] > comp[2*i+1];
    }
    return true;
  }
};
```

= 자료구조 보충
== 반복형 세그먼트 트리
점 대입, 구간 합. 구축 $O(N)$, 갱신·쿼리 $O(log N)$.
쿼리는 반열린 구간 `[l, r)`. 합 대신 다른 결합법칙 연산을 쓸 때는
항등원과 병합 연산도 바꾼다.
```cpp
struct SegTree {
  int n;
  vector<ll> t;
  SegTree(const vector<ll>& a) : n(1) {
    while (n < (int)a.size()) n <<= 1;
    t.assign(2*n, 0);
    copy(a.begin(), a.end(), t.begin() + n);
    for (int i = n-1; i; --i)
      t[i] = t[i<<1] + t[i<<1|1];
  }
  void set_value(int p, ll x) {
    for (t[p += n] = x; p > 1; p >>= 1)
      t[p>>1] = t[p] + t[p^1];
  }
  ll query(int l, int r) const {
    ll ans = 0;
    for (l += n, r += n; l < r;
      l >>= 1, r >>= 1) {
      if (l & 1) ans += t[l++];
      if (r & 1) ans += t[--r];
    }
    return ans;
  }
};
```

== Sparse Table (정적 RMQ)
배열 변경 불가. 구축 $O(N log N)$, 최솟값 질의 $O(1)$.
입력 배열과 질의 구간 `[l, r)`는 비어 있지 않아야 한다.
겹치는 두 구간을 사용하므로 합 연산에는 그대로 적용할 수 없다.
```cpp
struct SparseMin {
  vector<int> lg;
  vector<vector<ll>> st;
  SparseMin(const vector<ll>& a) {
    int n = a.size();
    assert(n > 0);
    lg.assign(n+1, 0);
    for (int i = 2; i <= n; ++i)
      lg[i] = lg[i/2] + 1;
    st.assign(lg[n]+1, vector<ll>(n));
    st[0] = a;
    for (int k = 1; k <= lg[n]; ++k)
      for (int i = 0; i+(1<<k) <= n; ++i)
        st[k][i] = min(st[k-1][i],
          st[k-1][i+(1<<(k-1))]);
  }
  ll query(int l, int r) const {
    int k = lg[r-l];
    return min(st[k][l], st[k][r-(1<<k)]);
  }
};
```

== 단조 덱 슬라이딩 윈도 최솟값
$O(N)$ 시간, $O(K)$ 공간. `1 <= k <= a.size()`.
완성된 길이 $K$ 윈도의 최솟값만 반환한다.
기존 노트의 우선순위 큐 구현과 달리 각 원소는 한 번씩만 삽입·삭제된다.
```cpp
vector<ll> window_min(const vector<ll>& a, int k) {
  deque<int> q;
  vector<ll> ans;
  for (int i = 0; i < (int)a.size(); ++i) {
    while (!q.empty() && q.front() <= i-k)
      q.pop_front();
    while (!q.empty() && a[q.back()] >= a[i])
      q.pop_back();
    q.push_back(i);
    if (i+1 >= k) ans.push_back(a[q.front()]);
  }
  return ans;
}
```

= 문자열 보충
== Z 알고리즘
$O(N)$. `z[i]`는 문자열 전체와 `s[i:]`의 최장 공통 접두사 길이.
여기서는 `z[0] = n`. 패턴 검색은 `패턴 + 구분자 + 본문`에 적용하며,
구분자는 패턴·본문에 없는 문자여야 한다.
```cpp
vector<int> z_function(const string& s) {
  int n = s.size(), l = 0, r = 0;
  vector<int> z(n);
  if (n) z[0] = n;
  for (int i = 1; i < n; ++i) {
    if (i < r) z[i] = min(r-i, z[i-l]);
    while (i+z[i] < n && s[z[i]] == s[i+z[i]])
      ++z[i];
    if (i+z[i] > r) { l = i; r = i+z[i]; }
  }
  return z;
}
```

= 정수론과 조합
== 모듈러 거듭제곱
$O(log E)$. `e >= 0`, `mod >= 1`.
곱셈은 128비트로 계산한다. 소수 모듈러 $p$에서
$a$가 $p$의 배수가 아니면 역원은 `mod_pow(a, p-2, p)`.
```cpp
ll mod_pow(ll a, ll e, ll mod) {
  a %= mod;
  if (a < 0) a += mod;
  ll r = 1 % mod;
  while (e) {
    if (e & 1) r = (i128)r * a % mod;
    a = (i128)a * a % mod;
    e >>= 1;
  }
  return r;
}
```

== 선형 체와 소인수분해
구축 $O(N)$, 공간 $O(N)$. `spf[x]`는 최소 소인수.
분해 입력은 `1 <= x <= n`. 1의 분해 결과는 빈 벡터.
```cpp
struct Sieve {
  vector<int> spf, primes;
  Sieve(int n) : spf(n+1) {
    for (int i = 2; i <= n; ++i) {
      if (!spf[i]) {
        spf[i] = i; primes.push_back(i);
      }
      for (int p : primes) {
        if (p > spf[i] || 1LL*i*p > n)
          break;
        spf[i*p] = p;
      }
    }
  }
  vector<pair<int, int>> factor(int x) const {
    vector<pair<int, int>> ans;
    while (x > 1) {
      int p = spf[x], e = 0;
      do { x /= p; ++e; }
      while (x % p == 0);
      ans.push_back({p, e});
    }
    return ans;
  }
};
```

== 확장 유클리드와 일반 CRT
`egcd(a,b,x,y)`는 $a x + b y = gcd(a,b)$.
CRT는 서로소가 아닌 양의 모듈러도 허용하며 $O(log min(m,n))$.
`crt(a,m,b,n)`은 두 합동식의 (최소 비음수 해, 최소공배수)를 반환.
해가 없으면 `(0,-1)`. 최소공배수는 `long long` 범위 이내여야 한다.
확장 유클리드 입력은 비음수이며 중간 계수 계산은 128비트를 사용한다.
```cpp
ll egcd(ll a, ll b, i128& x, i128& y) {
  if (!b) { x = 1; y = 0; return a; }
  i128 u, v;
  ll g = egcd(b, a % b, u, v);
  x = v; y = u - (i128)(a / b) * v;
  return g;
}
pair<ll, ll> crt(ll a, ll m, ll b, ll n) {
  a %= m; if (a < 0) a += m;
  b %= n; if (b < 0) b += n;
  i128 x, y;
  ll g = egcd(m, n, x, y), diff = b-a;
  if (diff % g) return {0, -1};
  ll ng = n/g;
  i128 k = (i128)(diff/g) * x % ng;
  if (k < 0) k += ng;
  i128 lcm = (i128)m * ng;
  assert(lcm <= numeric_limits<ll>::max());
  ll r = ((i128)a + (i128)m*k) % lcm;
  return {r, (ll)lcm};
}
```

== 팩토리얼 기반 이항계수
소수 모듈러 `p`, `0 <= N < p` 전용. `mod_pow` 필요.
전처리 $O(N + log p)$, 질의 $O(1)$. `n <= N`인 질의만 사용.
```cpp
struct Comb {
  ll p;
  vector<ll> fac, invfac;
  Comb(int n, ll p) : p(p), fac(n+1), invfac(n+1) {
    fac[0] = 1;
    for (int i = 1; i <= n; ++i)
      fac[i] = (i128)fac[i-1] * i % p;
    invfac[n] = mod_pow(fac[n], p-2, p);
    for (int i = n; i > 0; --i)
      invfac[i-1] = (i128)invfac[i] * i % p;
  }
  ll choose(int n, int r) const {
    if (r < 0 || r > n) return 0;
    return (i128)fac[n] * invfac[r] % p
      * invfac[n-r] % p;
  }
};
```

= DP와 수열
== LIS 길이와 경로 복원
엄격히 증가하는 부분 수열, $O(N log N)$.
반환값은 선택한 원소의 원본 인덱스.
비감소 수열은 `lower_bound`를 `upper_bound`로 변경한다.
```cpp
vector<int> lis_indices(const vector<ll>& a) {
  vector<ll> tail;
  vector<int> at, prev(a.size(), -1);
  for (int i = 0; i < (int)a.size(); ++i) {
    int k = lower_bound(tail.begin(),
              tail.end(), a[i]) - tail.begin();
    if (k) prev[i] = at[k-1];
    if (k == (int)tail.size()) {
      tail.push_back(a[i]); at.push_back(i);
    } else {
      tail[k] = a[i]; at[k] = i;
    }
  }
  vector<int> ans;
  if (!at.empty())
    for (int i = at.back(); i != -1; i = prev[i])
      ans.push_back(i);
  reverse(ans.begin(), ans.end());
  return ans;
}
```

== 0/1 배낭
각 물건은 최대 1번, 무게는 양의 정수. $O(N W)$ 시간, $O(W)$ 공간.
용량 이하 최대 가치이며 빈 선택 허용. 역방향 갱신이 핵심.
무제한 배낭은 무게 루프를 정방향으로 바꾼다.
```cpp
ll knapsack01(const vector<pair<int, ll>>& items,
        int capacity) {
  vector<ll> dp(capacity+1, 0);
  for (auto [w, v] : items)
    for (int c = capacity; c >= w; --c)
      dp[c] = max(dp[c], dp[c-w] + v);
  return dp[capacity];
}
```

= 기하 보충
== 끝점·겹침을 포함한 선분 교차
기존의 엄격한 교차 판정과 달리 끝점 접촉, 일직선 겹침,
길이가 0인 선분도 포함. $O(1)$.
좌표 절댓값 $10^9$ 이하 기준으로 외적은 128비트를 사용한다.
```cpp
using Point = pair<ll, ll>;
i128 cross(Point a, Point b, Point c) {
  return ((i128)b.first-a.first)
    * ((i128)c.second-a.second)
    - ((i128)b.second-a.second)
    * ((i128)c.first-a.first);
}
int sign128(i128 x) { return (x > 0) - (x < 0); }
bool intersects(Point a, Point b, Point c, Point d) {
  int ab_c = sign128(cross(a, b, c));
  int ab_d = sign128(cross(a, b, d));
  int cd_a = sign128(cross(c, d, a));
  int cd_b = sign128(cross(c, d, b));
  if (!ab_c && !ab_d && !cd_a && !cd_b) {
    if (b < a) swap(a, b);
    if (d < c) swap(c, d);
    return max(a, c) <= min(b, d);
  }
  return ab_c * ab_d <= 0 && cd_a * cd_b <= 0;
}
```

= 탐색과 전처리
== 정수 매개변수 탐색
`ok(x)`가 거짓에서 참으로 한 번만 바뀔 때, `[lo, hi]`의 첫 참을 찾는다.
`ok(hi)`는 참이어야 한다. $O(log("hi"-"lo"+1))$회 판정.
최대 참을 찾을 때는 판정 방향과 중간값 올림을 함께 바꿔야 한다.
```cpp
template<class F>
ll first_true(ll lo, ll hi, F ok) {
  while (lo < hi) {
    ll mid = (i128)lo + ((i128)hi-lo)/2;
    if (ok(mid)) hi = mid;
    else lo = mid+1;
  }
  return lo;
}
```

== 좌표 압축
$O(N log N)$. 정렬된 고유값을 반환하며 압축 인덱스는 `lower_bound`로 찾는다.
순서만 보존하고 실제 거리·길이는 보존하지 않는다.
```cpp
vector<ll> compress_values(vector<ll> a) {
  sort(a.begin(), a.end());
  a.erase(unique(a.begin(), a.end()), a.end());
  return a;
}
// auto xs = compress_values(a);
// int id = lower_bound(xs.begin(), xs.end(), x)
//   - xs.begin();
```

== 2차원 누적합
직사각형 배열 구축 $O(H W)$, 질의 $O(1)$.
질의는 `[r1, r2) x [c1, c2)`이며 빈 직사각형도 허용.
합과 중간 계산이 `long long` 범위 이내여야 한다.
```cpp
struct Prefix2D {
  vector<vector<ll>> p;
  Prefix2D(const vector<vector<ll>>& a) {
    int h = a.size(), w = h ? a[0].size() : 0;
    p.assign(h+1, vector<ll>(w+1));
    for (int r = 0; r < h; ++r)
      for (int c = 0; c < w; ++c)
        p[r+1][c+1] = a[r][c] + p[r][c+1]
          + p[r+1][c] - p[r][c];
  }
  ll query(int r1, int c1, int r2, int c2) const {
    return p[r2][c2] - p[r1][c2]
      - p[r2][c1] + p[r1][c1];
  }
};
```

== 병합 정렬로 역전쌍 개수
$i < j$이면서 $a_i > a_j$인 쌍의 수. $O(N log N)$ 시간, $O(N)$ 공간.
입력 배열은 정렬된다. 같은 값은 역전쌍에 포함하지 않는다.
```cpp
ll inversion_count(vector<ll>& a) {
  vector<ll> buf(a.size());
  function<ll(int,int)> solve = [&](int l, int r) {
    if (r-l <= 1) return 0LL;
    int m = (l+r)/2, i = l, j = m, k = l;
    ll ans = solve(l,m) + solve(m,r);
    while (i < m && j < r) {
      if (a[i] <= a[j]) buf[k++] = a[i++];
      else { ans += m-i; buf[k++] = a[j++]; }
    }
    while (i < m) buf[k++] = a[i++];
    while (j < r) buf[k++] = a[j++];
    copy(buf.begin()+l, buf.begin()+r, a.begin()+l);
    return ans;
  };
  return solve(0, a.size());
}
```

= 그래프 추가
== 벨만–포드와 음수 사이클 영향
방향 그래프, 음수 간선 허용. $O(V E + V + E)$.
시작점에서 도달 가능한 음수 사이클 및 그 이후 정점은 `negative[v] = 1`.
도달 불가는 `INF64`, 음수 사이클 영향을 받는 거리는 `-INF64`.
그 외 최단 거리의 절댓값은 `INF64` 미만이어야 한다.
내부 완화는 128비트로 계산하여 음수 사이클의 반복 감소를 처리한다.
```cpp
struct BFEdge { int u, v; ll w; };
struct BFResult {
  vector<ll> dist;
  vector<int> negative;
};
BFResult bellman_ford(int n, const vector<BFEdge>& e,
  int s) {
  const i128 BIG = (i128)1 << 120;
  vector<i128> d(n, BIG);
  vector<vector<int>> g(n);
  vector<int> neg(n);
  queue<int> q;
  for (auto [u,v,w] : e) g[u].push_back(v);
  d[s] = 0;
  for (int k = 0; k < n; ++k) {
    bool changed = false;
    for (auto [u,v,w] : e) {
      if (d[u] == BIG || d[v] <= d[u]+w) continue;
      d[v] = d[u]+w; changed = true;
      if (k == n-1 && !neg[v]) {
        neg[v] = 1; q.push(v);
      }
    }
    if (!changed) break;
  }
  while (!q.empty()) {
    int u = q.front(); q.pop();
    for (int v : g[u]) if (!neg[v]) {
      neg[v] = 1; q.push(v);
    }
  }
  vector<ll> ans(n, INF64);
  for (int i = 0; i < n; ++i) {
    if (neg[i]) ans[i] = -INF64;
    else if (d[i] != BIG) {
      assert(-INF64 < d[i] && d[i] < INF64);
      ans[i] = (ll)d[i];
    }
  }
  return {ans, neg};
}
```

== 오일러 경로 (무방향 Hierholzer)
모든 간선을 정확히 한 번 지나는 정점열. 평행 간선·자기 루프 허용.
$O(V + E)$. 홀수 차수 정점이 0개 또는 2개이며,
간선이 있는 정점들이 연결되어야 한다. 실패 시 빈 벡터.
정점이 있고 간선이 없으면 `{0}`을 반환한다.
```cpp
vector<int> euler_undirected(int n,
  const vector<pair<int,int>>& edges) {
  if (!n) return {};
  int m = edges.size(), start = 0;
  vector<vector<pair<int,int>>> g(n);
  for (int i = 0; i < m; ++i) {
    auto [u,v] = edges[i];
    g[u].push_back({v,i}); g[v].push_back({u,i});
  }
  vector<int> odd;
  for (int u = 0; u < n; ++u) {
    if (!g[u].empty()) start = u;
    if (g[u].size()%2) odd.push_back(u);
  }
  if (odd.size() != 0 && odd.size() != 2) return {};
  if (!odd.empty()) start = odd[0];
  vector<int> used(m), ptr(n), stk{start}, path;
  while (!stk.empty()) {
    int u = stk.back();
    while (ptr[u] < (int)g[u].size()
      && used[g[u][ptr[u]].second]) ++ptr[u];
    if (ptr[u] == (int)g[u].size()) {
      path.push_back(u); stk.pop_back();
    } else {
      auto [v,id] = g[u][ptr[u]++];
      used[id] = 1; stk.push_back(v);
    }
  }
  if ((int)path.size() != m+1) return {};
  reverse(path.begin(), path.end());
  return path;
}
```

= 구간 질의 추가
== Mo's Algorithm (서로 다른 값 개수)
갱신 없는 오프라인 질의. 구간은 `[l, r)`이며 빈 구간 허용.
배열 값은 `0 <= a[i] < value_count`로 좌표 압축한 뒤 사용.
시간 $O((N + Q) sqrt(N) + Q log Q)$, 공간 $O(N + Q + V)$.
다른 통계는 원소 추가·제거 시 답을 갱신하는 부분을 바꾼다.
```cpp
vector<int> mo_distinct(const vector<int>& a,
  const vector<pair<int,int>>& ranges, int value_count) {
  int n = a.size(), q = ranges.size(), block = 1;
  while (1LL*block*block < max(1,n)) ++block;
  vector<int> order(q), freq(value_count), ans(q);
  iota(order.begin(), order.end(), 0);
  sort(order.begin(), order.end(), [&](int x, int y) {
    int bx = ranges[x].first/block;
    int by = ranges[y].first/block;
    if (bx != by) return bx < by;
    return bx%2 ? ranges[x].second > ranges[y].second
      : ranges[x].second < ranges[y].second;
  });
  int l = 0, r = 0, distinct = 0;
  auto add = [&](int i) {
    if (freq[a[i]]++ == 0) ++distinct;
  };
  auto del = [&](int i) {
    if (--freq[a[i]] == 0) --distinct;
  };
  for (int id : order) {
    auto [ql,qr] = ranges[id];
    while (l > ql) add(--l);
    while (r < qr) add(r++);
    while (l < ql) del(l++);
    while (r > qr) del(--r);
    ans[id] = distinct;
  }
  return ans;
}
```

== 영속 세그먼트 트리 (구간 K번째)
값을 `[0, sigma)`로 압축. `sigma >= 1`.
노드 0은 빈 트리. 접두사별 루트를 `roots[i+1] = add(roots[i], a[i])`로 구축.
`kth(roots[l], roots[r], k)`는 `[l, r)`의 1-indexed K번째 값의 압축 인덱스.
`1 <= k <= r-l`. 구축 $O(N log sigma)$, 질의 $O(log sigma)$.
```cpp
struct PersistentKth {
  struct Node { int l = 0, r = 0, cnt = 0; };
  int sigma;
  vector<Node> t;
  PersistentKth(int sigma) : sigma(sigma), t(1) {}
  int add(int root, int pos) {
    return add_impl(root, 0, sigma, pos);
  }
  int add_impl(int old, int l, int r, int pos) {
    int u = t.size();
    Node node = t[old];
    t.push_back(node); ++t[u].cnt;
    if (r-l == 1) return u;
    int m = (l+r)/2;
    if (pos < m) {
      int v = add_impl(t[u].l, l, m, pos);
      t[u].l = v;
    } else {
      int v = add_impl(t[u].r, m, r, pos);
      t[u].r = v;
    }
    return u;
  }
  int kth(int left, int right, int k) const {
    int l = 0, r = sigma;
    while (r-l > 1) {
      int cnt = t[t[right].l].cnt - t[t[left].l].cnt;
      int m = (l+r)/2;
      if (k <= cnt) {
        left = t[left].l; right = t[right].l; r = m;
      } else {
        k -= cnt;
        left = t[left].r; right = t[right].r; l = m;
      }
    }
    return l;
  }
};
```

== Li Chao Tree (직선 최솟값)
질의할 모든 정수 x좌표를 생성자에 전달. 정렬·중복 제거 후 비어 있지 않아야 한다.
`add(a,b)`로 $y = a x + b$ 삽입, `query(x)`는 등록한 좌표만 허용.
구축 $O(X log X)$, 삽입·질의 $O(log X)$, 공간 $O(X)$.
곱셈과 비교는 128비트. 모든 직선값의 절댓값은 $2^120$ 미만이어야 한다.
직선이 없으면 $2^120$을 반환. DP의 직선 형태 점화식 최적화에 사용.
```cpp
struct LiChao {
  struct Line {
    ll a = 0, b = 0;
    bool empty = true;
    i128 at(ll x) const {
      return empty ? (i128)1<<120 : (i128)a*x+b;
    }
  };
  vector<ll> xs;
  vector<Line> t;
  LiChao(vector<ll> x) : xs(compress_values(x)) {
    assert(!xs.empty()); t.resize(4*xs.size());
  }
  void insert(Line f, int u, int l, int r) {
    int m = (l+r)/2;
    bool left = f.at(xs[l]) < t[u].at(xs[l]);
    bool mid = f.at(xs[m]) < t[u].at(xs[m]);
    if (mid) swap(f,t[u]);
    if (r-l == 1 || f.empty) return;
    if (left != mid) insert(f,u*2,l,m);
    else insert(f,u*2+1,m,r);
  }
  void add(ll a, ll b) {
    insert({a,b,false},1,0,xs.size());
  }
  i128 query(ll x) const {
    int pos = lower_bound(xs.begin(),xs.end(),x)
      - xs.begin();
    assert(pos < (int)xs.size() && xs[pos] == x);
    int u = 1, l = 0, r = xs.size();
    i128 ans = (i128)1<<120;
    while (true) {
      ans = min(ans,t[u].at(x));
      if (r-l == 1) return ans;
      int m = (l+r)/2;
      if (pos < m) { u *= 2; r = m; }
      else { u = u*2+1; l = m; }
    }
  }
};
```

= 문자열 추가
== 아호–코라식 (다중 패턴 출현 횟수)
알파벳은 소문자 a-z, 빈 패턴 불가. `insert`가 반환한 노드 번호를 저장.
모든 패턴을 삽입한 후 `build()`는 한 번만 호출하고, 이후 삽입하지 않는다.
`count(text)[terminal]`은 해당 패턴 출현 횟수. 겹침·중복 패턴 허용.
총 패턴 길이 $S$, 본문 길이 $T$일 때 구축 $O(26 S)$,
검색 $O(T + S)$, 공간 $O(26 S)$.
```cpp
struct AhoCorasick {
  struct Node {
    array<int,26> next;
    int link = 0;
    Node() { next.fill(-1); }
  };
  vector<Node> t = vector<Node>(1);
  vector<int> order;
  int insert(const string& s) {
    int u = 0;
    for (char ch : s) {
      int c = ch-'a';
      if (t[u].next[c] == -1) {
        int v = t.size();
        t[u].next[c] = v; t.emplace_back();
      }
      u = t[u].next[c];
    }
    return u;
  }
  void build() {
    queue<int> q;
    for (int c = 0; c < 26; ++c) {
      int v = t[0].next[c];
      if (v == -1) t[0].next[c] = 0;
      else q.push(v);
    }
    while (!q.empty()) {
      int u = q.front(); q.pop(); order.push_back(u);
      for (int c = 0; c < 26; ++c) {
        int v = t[u].next[c];
        int f = t[t[u].link].next[c];
        if (v == -1) t[u].next[c] = f;
        else { t[v].link = f; q.push(v); }
      }
    }
  }
  vector<ll> count(const string& s) const {
    vector<ll> cnt(t.size());
    int u = 0;
    for (char ch : s) {
      u = t[u].next[ch-'a']; ++cnt[u];
    }
    for (int i = (int)order.size()-1; i >= 0; --i) {
      int v = order[i]; cnt[t[v].link] += cnt[v];
    }
    return cnt;
  }
};
```

== 이중 롤링 해시
전처리 $O(N)$, 부분 문자열 `[l, r)` 해시 $O(1)$.
같은 길이의 부분 문자열끼리 비교한다. 충돌 가능성이 있으므로 결정적 판정이
필요한 문제는 접미사 배열·KMP 등을 사용하거나 실제 문자열을 추가 검증한다.
```cpp
struct DoubleHash {
  static constexpr ll P = 1000000007, Q = 1000000009;
  static constexpr ll B = 911382323;
  vector<ll> h1,h2,p1,p2;
  DoubleHash(const string& s) {
    int n = s.size();
    h1.resize(n+1); h2.resize(n+1);
    p1.assign(n+1,1); p2.assign(n+1,1);
    for (int i = 0; i < n; ++i) {
      int c = (unsigned char)s[i]+1;
      h1[i+1] = (h1[i]*B+c)%P;
      h2[i+1] = (h2[i]*B+c)%Q;
      p1[i+1] = p1[i]*B%P; p2[i+1] = p2[i]*B%Q;
    }
  }
  pair<ll,ll> get(int l, int r) const {
    return {(h1[r]-h1[l]*p1[r-l]%P+P)%P,
      (h2[r]-h2[l]*p2[r-l]%Q+Q)%Q};
  }
};
```

= 수학 추가
== 오일러 피 함수 체
$phi(n)$은 1부터 $n$ 중 $n$과 서로소인 수의 개수. `phi[1] = 1`.
$O(N log log N)$ 시간, $O(N)$ 공간.
```cpp
vector<int> phi_sieve(int n) {
  vector<int> phi(n+1);
  iota(phi.begin(),phi.end(),0);
  for (int p = 2; p <= n; ++p)
    if (phi[p] == p)
      for (int x = p; x <= n; x += p)
        phi[x] -= phi[x]/p;
  return phi;
}
```

== Miller–Rabin (64비트 결정적 소수 판정)
부호 없는 64비트 전체 범위. 고정된 7개 밑을 모두 사용해야 결정적이다.
128비트 곱셈 사용. $O(7 log N)$ 모듈러 연산.
소인수분해가 아니라 소수 여부만 판정한다.
```cpp
using u64 = unsigned long long;
using u128 = __uint128_t;
u64 mul_mod64(u64 a, u64 b, u64 m) {
  return (u128)a*b%m;
}
u64 pow_mod64(u64 a, u64 e, u64 m) {
  u64 r = 1;
  for (; e; e >>= 1, a = mul_mod64(a,a,m))
    if (e&1) r = mul_mod64(r,a,m);
  return r;
}
bool is_prime64(u64 n) {
  if (n < 2) return false;
  for (u64 p : {2,3,5,7,11,13,17,19,23,29,31,37}) {
    if (n%p == 0) return n == p;
  }
  u64 d = n-1; int s = 0;
  while (!(d&1)) { d >>= 1; ++s; }
  for (u64 a : {2ULL,325ULL,9375ULL,28178ULL,
    450775ULL,9780504ULL,1795265022ULL}) {
    if (a%n == 0) continue;
    u64 x = pow_mod64(a%n,d,n);
    if (x == 1 || x == n-1) continue;
    bool pass = false;
    for (int r = 1; r < s; ++r) {
      x = mul_mod64(x,x,n);
      if (x == n-1) { pass = true; break; }
    }
    if (!pass) return false;
  }
  return true;
}
```

== NTT 합성곱
계수 모듈러는 998244353, 원시근 3. `mod_pow` 필요.
입력 계수는 `[0, MOD)`로 정규화. 결과 길이는 $A + B - 1$.
변환 길이는 그 이상인 최소 2의 거듭제곱이고 $2^23$ 이하여야 한다.
$O(L log L)$ 시간, $O(L)$ 공간. 일반 정수의 정확한 곱은 여러 소수와 CRT 필요.
```cpp
constexpr int NTT_MOD = 998244353;
void ntt(vector<int>& a, bool inverse) {
  int n = a.size();
  for (int i = 1, j = 0; i < n; ++i) {
    int bit = n>>1;
    for (; j&bit; bit >>= 1) j ^= bit;
    j ^= bit;
    if (i < j) swap(a[i],a[j]);
  }
  for (int len = 2; len <= n; len <<= 1) {
    ll root = mod_pow(3,(NTT_MOD-1)/len,NTT_MOD);
    if (inverse) root = mod_pow(root,NTT_MOD-2,NTT_MOD);
    for (int i = 0; i < n; i += len) {
      ll w = 1;
      for (int j = 0; j < len/2; ++j) {
        int u = a[i+j], v = a[i+j+len/2]*w%NTT_MOD;
        a[i+j] = (u+v)%NTT_MOD;
        a[i+j+len/2] = (u-v+NTT_MOD)%NTT_MOD;
        w = w*root%NTT_MOD;
      }
    }
  }
  if (inverse) {
    ll inv = mod_pow(n,NTT_MOD-2,NTT_MOD);
    for (int& x : a) x = x*inv%NTT_MOD;
  }
}
vector<int> convolution(vector<int> a, vector<int> b) {
  if (a.empty() || b.empty()) return {};
  int need = a.size()+b.size()-1, n = 1;
  while (n < need) n <<= 1;
  assert(n <= (1<<23));
  a.resize(n); b.resize(n);
  ntt(a,false); ntt(b,false);
  for (int i = 0; i < n; ++i)
    a[i] = (ll)a[i]*b[i]%NTT_MOD;
  ntt(a,true); a.resize(need);
  return a;
}
```

== 행렬 거듭제곱
정방 행렬, 지수 `e >= 0`, `mod >= 1`. 원소는 `[0, mod)`.
$O(N^3 log E)$ 시간, $O(N^2)$ 공간. 선형 점화식과 길이 K의 경로 개수에 사용.
곱셈·덧셈은 128비트로 계산한다.
```cpp
using Matrix = vector<vector<ll>>;
Matrix mat_mul(const Matrix& a, const Matrix& b, ll mod) {
  int n = a.size();
  Matrix c(n,vector<ll>(n));
  for (int i = 0; i < n; ++i)
    for (int k = 0; k < n; ++k)
      for (int j = 0; j < n; ++j)
        c[i][j] = (c[i][j]+(i128)a[i][k]*b[k][j])%mod;
  return c;
}
Matrix mat_pow(Matrix a, ll e, ll mod) {
  int n = a.size();
  Matrix r(n,vector<ll>(n));
  for (int i = 0; i < n; ++i) r[i][i] = 1%mod;
  while (e) {
    if (e&1) r = mat_mul(r,a,mod);
    a = mat_mul(a,a,mod); e >>= 1;
  }
  return r;
}
```

= DP 추가
== LCS 길이와 문자열 복원
최장 공통 부분 수열. $O(N M)$ 시간·공간.
길이만 필요하면 이전·현재 행만 유지하여 공간을 $O(min(N,M))$으로 줄일 수 있다.
```cpp
string lcs(const string& a, const string& b) {
  int n = a.size(), m = b.size();
  vector<vector<int>> dp(n+1,vector<int>(m+1));
  for (int i = 1; i <= n; ++i)
    for (int j = 1; j <= m; ++j)
      dp[i][j] = a[i-1] == b[j-1] ? dp[i-1][j-1]+1
        : max(dp[i-1][j],dp[i][j-1]);
  string ans;
  while (n && m) {
    if (a[n-1] == b[m-1]) {
      ans += a[--n]; --m;
    } else if (dp[n-1][m] >= dp[n][m-1]) --n;
    else --m;
  }
  reverse(ans.begin(),ans.end());
  return ans;
}
```

== 비트마스크 외판원 순회 (Held–Karp)
정점 0에서 출발, 모든 정점을 한 번씩 방문 후 0으로 복귀.
비용 행렬에서 간선 없음은 `INF64`. 0 비용 간선도 허용.
$O(N^2 2^N)$ 시간, $O(N 2^N)$ 공간. `1 <= N <= 20` 권장,
N=20에서 DP만 약 160 MiB. 경로 비용 합의 절댓값은 `INF64` 미만.
정점 하나이면 0, 순회 불가이면 `INF64`.
```cpp
ll tsp(const Matrix& w) {
  int n = w.size();
  if (n == 1) return 0;
  int all = 1<<n;
  vector<vector<ll>> dp(all,vector<ll>(n,INF64));
  dp[1][0] = 0;
  for (int mask = 1; mask < all; ++mask) {
    for (int u = 0; u < n; ++u) {
      if (dp[mask][u] == INF64) continue;
      for (int v = 0; v < n; ++v) {
        if ((mask>>v&1) || w[u][v] == INF64) continue;
        ll& to = dp[mask|(1<<v)][v];
        to = min(to,dp[mask][u]+w[u][v]);
      }
    }
  }
  ll ans = INF64;
  for (int u = 1; u < n; ++u)
    if (dp[all-1][u] != INF64 && w[u][0] != INF64)
      ans = min(ans,dp[all-1][u]+w[u][0]);
  return ans;
}
```

== 부분집합 합 변환 (SOS DP)
길이 $2^B$ 배열. 변환 후 `f[mask]`는 모든 부분집합 `sub`의 원래 값의 합.
$O(B 2^B)$ 시간, 추가 공간 $O(1)$. 역변환은 덧셈을 뺄셈으로 바꾼다.
상위집합 합은 해당 비트가 0인 마스크에 비트를 켠 값을 더한다.
합이 자료형 범위를 넘지 않아야 한다.
```cpp
void subset_zeta(vector<ll>& f, int bits) {
  assert(f.size() == (1ULL<<bits));
  for (int b = 0; b < bits; ++b)
    for (int mask = 0; mask < (1<<bits); ++mask)
      if (mask>>b&1) f[mask] += f[mask^(1<<b)];
}
```

= 기하 추가
== 다각형 넓이와 점 포함 판정
꼭짓점은 단순 다각형의 경계 순서. `Point`, `cross`는 앞선 기하 보충 코드 사용.
넓이는 부호 있는 넓이의 2배를 반환하며 절댓값을 2로 나누면 실제 넓이.
점 판정은 경계 0, 내부 1, 외부 -1. 각각 $O(N)$.
정수 좌표 절댓값 $10^9$ 이하에서 사용한다.
```cpp
i128 polygon_area2(const vector<Point>& p) {
  i128 sum = 0;
  int n = p.size();
  for (int i = 0; i < n; ++i) {
    auto [x,y] = p[i]; auto [u,v] = p[(i+1)%n];
    sum += (i128)x*v-(i128)y*u;
  }
  return sum;
}
int point_in_polygon(const vector<Point>& p, Point q) {
  int winding = 0, n = p.size();
  for (int i = 0; i < n; ++i) {
    Point a = p[i], b = p[(i+1)%n];
    i128 c = cross(a,b,q);
    if (!c && min(a.first,b.first) <= q.first
      && q.first <= max(a.first,b.first)
      && min(a.second,b.second) <= q.second
      && q.second <= max(a.second,b.second)) return 0;
    if (a.second <= q.second && q.second < b.second
      && c > 0) ++winding;
    if (b.second <= q.second && q.second < a.second
      && c < 0) --winding;
  }
  return winding ? 1 : -1;
}
```

= 알고리즘 추가
== 함수 그래프의 K번째 다음 정점
각 정점의 다음 정점이 정확히 하나인 함수 그래프. 정점은 0-indexed,
`next[v]`와 질의 정점은 모두 `[0, N)` 범위, $N$은 `int` 범위 이내.
전처리 $O(64 N)$ 시간·공간, 질의 $O(64)$. `k = 0`이면 시작 정점 반환.
```cpp
#include <cstdint>
#include <vector>
using namespace std;

struct Successor {
  vector<vector<int>> up;
  Successor(const vector<int>& next) : up(64, next) {
    for (int b = 1; b < 64; ++b)
      for (int v = 0; v < (int)next.size(); ++v)
        up[b][v] = up[b-1][up[b-1][v]];
  }
  int jump(int v, uint64_t k) const {
    for (int b = 0; b < 64; ++b)
      if ((k >> b) & 1) v = up[b][v];
    return v;
  }
};
```

== 트리의 모든 정점까지 거리 합 (재루팅)
무가중치 무방향 트리의 각 정점에서 다른 정점까지의 거리 합을 반환.
정점은 0-indexed, 간선은 양쪽 인접 리스트에 넣는다. 빈 트리도 허용.
$O(N)$ 시간·공간. 거리 합이 `long long` 범위 이내여야 한다.
```cpp
#include <vector>
using namespace std;

vector<long long> tree_distance_sums(const vector<vector<int>>& g) {
  int n = g.size();
  if (!n) return {};
  vector<int> parent(n, -1), order{0};
  for (int i = 0; i < n; ++i) {
    int u = order[i];
    for (int v : g[u]) if (v != parent[u]) {
      parent[v] = u; order.push_back(v);
    }
  }
  vector<long long> size(n, 1), ans(n, 0);
  for (int i = n-1; i > 0; --i) {
    int u = order[i], p = parent[u];
    size[p] += size[u]; ans[p] += ans[u] + size[u];
  }
  for (int i = 1; i < n; ++i) {
    int u = order[i];
    ans[u] = ans[parent[u]] + n - 2*size[u];
  }
  return ans;
}
```

== 헝가리안 알고리즘 (최소 비용 할당)
행마다 서로 다른 열 하나를 선택하는 최소 비용. 직사각형 행렬에서 `0 < N <= M`,
음수 비용 허용. 반환은 (비용, 행별 0-indexed 열). $O(N^2 M)$ 시간,
입력 외 $O(N + M)$ 공간. 모든 중간 계산의 절댓값이 `INF` 미만이어야 한다.
```cpp
#include <algorithm>
#include <limits>
#include <utility>
#include <vector>
using namespace std;

pair<long long, vector<int>> assignment(const vector<vector<long long>>& a) {
  int n = a.size(), m = a[0].size();
  const long long INF = numeric_limits<long long>::max()/4;
  vector<long long> u(n+1), v(m+1);
  vector<int> p(m+1), way(m+1);
  for (int i = 1; i <= n; ++i) {
    p[0] = i;
    int j0 = 0;
    vector<long long> minv(m+1, INF);
    vector<bool> used(m+1, false);
    do {
      used[j0] = true;
      int i0 = p[j0], j1 = 0;
      long long delta = INF;
      for (int j = 1; j <= m; ++j) if (!used[j]) {
        long long cur = a[i0-1][j-1] - u[i0] - v[j];
        if (cur < minv[j]) { minv[j] = cur; way[j] = j0; }
        if (minv[j] < delta) { delta = minv[j]; j1 = j; }
      }
      for (int j = 0; j <= m; ++j) {
        if (used[j]) { u[p[j]] += delta; v[j] -= delta; }
        else if (j) minv[j] -= delta;
      }
      j0 = j1;
    } while (p[j0]);
    do {
      int j1 = way[j0]; p[j0] = p[j1]; j0 = j1;
    } while (j0);
  }
  vector<int> match(n);
  long long cost = 0;
  for (int j = 1; j <= m; ++j) if (p[j]) {
    match[p[j]-1] = j-1; cost += a[p[j]-1][j-1];
  }
  return {cost, match};
}
```

== 편집 거리 (Levenshtein)
바이트 삽입·삭제·교체 비용이 각각 1. 빈 문자열 허용.
UTF-8 문자열은 문자 단위가 아닌 바이트 단위로 비교한다.
두 문자열 길이가 $N, M$일 때 $O((N+1)(M+1))$ 시간,
$O(min(N,M)+1)$ 공간. 각 길이는 `INT_MAX - 1` 이하여야 한다.
```cpp
#include <algorithm>
#include <numeric>
#include <string>
#include <vector>
using namespace std;

int edit_distance(const string& s, const string& t) {
  const string& a = s.size() >= t.size() ? s : t;
  const string& b = s.size() >= t.size() ? t : s;
  vector<int> prev(b.size()+1), cur(b.size()+1);
  iota(prev.begin(), prev.end(), 0);
  for (int i = 1; i <= (int)a.size(); ++i) {
    cur[0] = i;
    for (int j = 1; j <= (int)b.size(); ++j)
      cur[j] = min({prev[j]+1, cur[j-1]+1,
        prev[j-1]+(a[i-1] != b[j-1])});
    swap(prev, cur);
  }
  return prev[b.size()];
}
```

== XOR 선형 기저 (최대 부분집합 XOR)
부호 없는 64비트 수의 부분집합 XOR 최댓값. 빈 부분집합도 허용.
삽입·최댓값 질의 각각 $O(64)$, 공간 $O(64)$. 중복 삽입 가능.
```cpp
#include <algorithm>
#include <array>
#include <cstdint>
using namespace std;

struct XorBasis {
  array<uint64_t, 64> basis{};
  void insert(uint64_t x) {
    for (int b = 63; b >= 0; --b) if ((x >> b) & 1) {
      if (!basis[b]) { basis[b] = x; return; }
      x ^= basis[b];
    }
  }
  uint64_t maximum() const {
    uint64_t x = 0;
    for (int b = 63; b >= 0; --b) x = max(x, x ^ basis[b]);
    return x;
  }
};
```

== 자릿수 DP (인접 자릿수가 다른 수)
`count_no_adjacent(x)`는 0부터 x까지 인접한 십진 자릿수가 다른 정수의 개수.
선행 0은 자릿수로 세지 않으며 0도 포함. `x < 0`이면 0, `x <= 10^18`.
`0 <= l <= r <= 10^18`인 범위의 답은
`count_no_adjacent(r) - count_no_adjacent(l-1)`.
자릿수 $D$에 대해 $O(D dot 11 dot 2 dot 10)$ 시간, $O(11 dot 2)$ 공간.
```cpp
#include <string>
using namespace std;

long long count_no_adjacent(long long x) {
  if (x < 0) return 0;
  long long dp[11][2] = {};
  dp[10][1] = 1;
  for (char ch : to_string(x)) {
    long long next[11][2] = {};
    int digit = ch-'0';
    for (int prev = 0; prev <= 10; ++prev)
      for (int tight = 0; tight < 2; ++tight)
        for (int d = 0; d <= (tight ? digit : 9); ++d) {
          if (prev != 10 && prev == d) continue;
          int np = prev == 10 && d == 0 ? 10 : d;
          next[np][tight && d == digit] += dp[prev][tight];
        }
    for (int p = 0; p <= 10; ++p)
      for (int t = 0; t < 2; ++t) dp[p][t] = next[p][t];
  }
  long long ans = 0;
  for (auto& row : dp) ans += row[0] + row[1];
  return ans;
}
```
