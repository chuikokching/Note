# Note_SpringBoot

### SpringBoot

logback-spring.xml (管理日志文件)

gitignore (git管理文件)

mvn mvnw mvnw.cmd (maven管理)

application.properties (配置文件)

使用HTTP Client测试接口 http  -> test.http (测试接口文件 类似Postman)

**热部署 (修改立竿见影,不用重启项目):**

1. 在pom.xml中添加依赖

   ```xml
   <dependency>
       <groupId>org.springframework.boot</groupId>
       <artifactId>spring-boot-devtools</artifactId>
   </dependency>
   ```

2. 勾选Setting -> Compiler 的 Build project automatically

3. 勾选Help -> Find action -> Registry... 的 compiler automake ... running

4. 每次修改配置文件后点击斧头图标热部署 运行测试接口校验 

**常用标签:**

RequestMapping, GetMapping, PostMapping,..., Value, RestController[返回JSON], Controller[返回页面],ComponentScan[扫描类包], MapperScan[扫描MyBatis], Resource[将一个类注入到另一个类中]

**集成MyBatis: (3-5)**

Controller(入口, 调用Service List()) -> Service(调用Mapper List()) -> Mapper(定义一系列操作数据库的方法接口, 并建立数据实体类, 映射到Mapper.xml) -> Mapper.xml (集成Mapper和数据实体类的SQL, 执行SQL)

插件: Free myBatis plugin，Maven (Mybatis-generator, 需要配置generator-config.xml)

CommResp: 前后端对齐 添加泛型类 以后所有接口统一返回CommResp类型

#### 常见的持久层框架

主要有Mybatis、Hibernate两种持久层框架，前者为半自动，后者为全自动

Mybatis: 半自动的持久层框架有时需要程序员手写一些SQL语句, 灵活性高.

Hibernate: 全自动的持久层框架不需要程序员手写SQL语句, 几乎所有的事情都可以交给框架来做.

Mybatis：需要程序员手写SQL语句，可以严格控制sql执行性能，灵活度高。但是数据无关性差，如果是多种数据库的话，每种数据库都要编写专门的SQL语句，非常麻烦。

Hibernate：不需要程序员手写SQL语句，数据无关性好，可以适应多数据库类型的项目，但是比起Mybatis执行性能会差一些。

**泛型和Object的区别**

泛型和Object在使用上区别不大，但是泛型在使用时不需要做强制类型转换，编译时更安全。如果使用Object类的话，你没法保证返回的类型一定是需要的类型，也许是其它类型。这时你就会在运行时得到一个类型转换异常（ClassCastException）



**查看开源项目需要从整体架构出发再到局部功能实现, 关注配置文件**



### VUE

Vue, Vue CLI: Vue CLI = Vue.js + 一堆插件 

安装node.js -> npm install -g @vue/cli@version -> npm create web -> npm run serve

**目录结构：**

- node_modules: 各种js依赖的包
- public: 首页位置
- src: 代码位置
  1. assets: 静态资源
  2. components: 组件
  3. router: 路由 (lazy-loaded: 页面很多,不全部加载,减少初始包的大小)
  4. store: 全局数据
  5. views: 页面

-  App.vue: 初始页面
- main.ts: 初始启动配置文件  通过它把App.vue和index.html关联起来
- package.json: 类似后端pom.xml
- dist: bulid之后生成, 最终部署到服务器的文件

**集成Ant Design Vue**

npm install ant-design-vue@2.0.0-rc.3  --save, 在main.ts中添加导入并且use()关联起来.

**VitePress, VuePress**

