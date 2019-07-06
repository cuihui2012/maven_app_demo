<%@ page language="java" contentType="text/html; charset=UTF-8"
                pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <title>Test Page</title>
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/user.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/layui/css/layui.css" media="all">

    <script type="text/javascript" src="${pageContext.request.contextPath}/layui/layui.js"></script>
</head>

<body>
<!-- 工具条 -->
<script type="text/html" id="barDemo">
    <a class="layui-btn layui-btn-xs" lay-event="detail">查看</a>
    <a class="layui-btn layui-btn-xs" lay-event="edit">编辑</a>
    <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
</script>
<div class="top_tool">
    <div class="layui-form-item">
        <div class="layui-inline">
            <label class="layui-form-label">姓名</label>
            <div class="layui-input-inline">
                <input type="text" id="searchname" required  lay-verify="required" placeholder="请输入姓名" autocomplete="off" class="layui-input">
            </div>
        </div>
        <div class="layui-inline">
            <label class="layui-form-label">性别</label>
            <div class="layui-input-inline">
                <select id="searchsex" lay-verify="required" class="sex_select layui-input-inline">
                    <option value="">请选择</option>
                    <option value="1">男</option>
                    <option value="2">女</option>
                </select>
            </div>
        </div>
        <div class="layui-inline">
            <button class="layui-btn" data-type="reload" id="search-button">
                <i class="layui-icon">&#xe615;</i> 搜索
            </button>
            <!-- 新增按钮 -->
            <button class="layui-btn" type="button" id="add">
                <i class="layui-icon">&#xe608;</i> 添加
            </button>
        </div>
    </div>
</div>
<div class="layui-form">
    <!-- 表格 -->
    <table id="demo" lay-filter="test"></table>
</div>
<!-- 隐藏域放入工程路径 -->
<input id="PageContext" type="hidden" value="${pageContext.request.contextPath}" />
<script type="application/javascript">
layui.use(['table','jquery','form'], function(){
    var table = layui.table;
    var form = layui.form;
    var $ = layui.$;//重点处
    //第一个实例
    table.render({
        elem: '#demo' //对应表格元素
        ,id: 'test'
        ,height: $(window).height()-150
        ,url: $("#PageContext").val() + '/user/findAll' //数据接口,默认会带？page=1,limit=10,返回的数据有格式要求
        ,method: 'post'
        ,even: true //开启隔行背景
        ,page: true //开启分页
        ,cols: [[ //表头
            {field: 'uuid', title: '用户ID', width:300, sort: true, fixed: 'left'}
            ,{field: 'uname', title: '用户名', width:300}
            ,{field: 'sex', title: '性别', width:300, sort: true}
            ,{field: 'age', title: '年龄', width:300}
            ,{fixed: 'right', title: '操作', width:200, align:'center', toolbar: '#barDemo'} //这里的toolbar绑定工具条
        ]]
    });

    //监听行双击事件
    table.on('rowDouble(test)', function(obj){
        //obj 同上
        //弹出层处理
        layer.open({
            type:2, //2表示frame
            title:'用户信息',
            area:['500px','50%'],
            shadeClose:false,
            closeBtn:1,
            content:$("#PageContext").val() + '/pages/updateuser.jsp?uuid='+obj.data.uuid + '&flag=1', //flag有值为查看详情页
            end:function(){
                // table.reload('test'); //对应table.render中定义的id
            }
        });
    });

    //监听工具条
    table.on('tool(test)', function(obj){ //注：tool是工具条事件名，test是table lay-filter="对应的值"
        var data = obj.data; //获得当前行数据
        var layEvent = obj.event; //获得 lay-event 对应的值（也可以是表头的 event 参数对应的值）
        var tr = obj.tr; //获得当前行 tr 的DOM对象

        if(layEvent === 'detail'){ //查看
            //弹出层处理
            layer.open({
                type:2, //2表示frame
                title:'用户信息',
                area:['500px','50%'],
                shadeClose:false,
                closeBtn:1,
                content:$("#PageContext").val() + '/pages/updateuser.jsp?uuid='+data.uuid + '&flag=1', //flag有值为查看详情页
                end:function(){
                    // table.reload('test'); //对应table.render中定义的id
                }
            });
        } else if(layEvent === 'del'){ //删除
            layer.confirm('确定删除吗', function(index){
                obj.del(); //删除对应行（tr）的DOM结构，并更新缓存
                layer.close(index);
                //向服务端发送删除指令
                console.log(data);
                $.ajax({
                    type : 'POST',
                    url : $("#PageContext").val() + '/user/deleteUserByUuid',
                    dataType : 'json',
                    data : {
                        'uuid' : data.uuid
                    },
                    success : function(e){
                        //e为后台返回的数据
                        if(e == "1"){
                            layer.msg("用户删除成功");
                        }else{
                            layer.msg("用户删除失败，请稍后再试...");
                        }
                    },
                    error : function(){
                        layer.msg("服务器开小差了，请稍后再试...");
                    }
                });
            });
        } else if(layEvent === 'edit'){ //编辑
            //弹出层处理
            layer.open({
                type:2, //2表示frame
                title:'用户信息',
                area:['500px','50%'],
                shadeClose:false,
                closeBtn:1,
                content:$("#PageContext").val() + '/pages/updateuser.jsp?uuid='+data.uuid,
                end:function(){
                    table.reload('test'); //对应table.render中定义的id
                }
            });
        }
    });

    //新增按钮点击事件
    $("#add").bind("click",function(){
        //弹出层处理
        layer.open({
            type:2, //2表示frame
            title:'用户信息',
            area:['500px','50%'],
            shadeClose:false,
            closeBtn:1,
            content:$("#PageContext").val() + '/pages/updateuser.jsp',
            end:function(){
                table.reload('test'); //对应table.render中定义的id
            }
        });
    });

    //搜索功能
    $('#search-button').on('click', function(){
        //执行重载
        table.reload('test', {
            page: {
                curr: 1 //重新从第 1 页开始
            }
            ,where: {
                'uname': $('#searchname').val(),
                'sex':$('#searchsex option:selected').val()
            }
        });
    });
});
</script>
</body>

</html>