<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib uri = "http://java.sun.com/jsp/jstl/core" prefix = "c"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
    <meta charset="utf-8">
    <title>日历组件示例</title>
    <style>
        .calendar{font-family:Tahoma; background:#fff; float:left; border-style:solid; border-width:1px; border-color:#85BEE5 #3485C0 #3485C0 #85BEE5; position:relative; padding:10px; }
        .calendar dl,.calendar dd{margin:0; padding:0; width:183px; font-size:12px; line-height:22px;}
        .calendar dt.title-date{ display:block; border-bottom:1px solid #E4E4E4; font-weight:700; position:relative; margin-bottom:5px; padding-bottom:3px;}
        .calendar dt{ float:left; width:25px; margin-left:1px; text-align:center;}
        .calendar dt.title-date{ width:100%;}
        .calendar dd{clear: both;width: 183px;height: 139px;font-weight: 700;background:url(http://images.cnblogs.com/cnblogs_com/NNUF/379856/o_bg.png) no-repeat; margin:0;}
        .prevyear,.nextyear, .prevmonth,.nextmonth{cursor:pointer;height:9px; background:url(http://images.cnblogs.com/cnblogs_com/NNUF/379856/o_nextprv.png) no-repeat; overflow:hidden;position:absolute; top:8px; text-indent:-999px;}
        .prevyear{  left:4px;  width:9px;}
        .prevmonth{ width:5px; background-position:-9px 0; left:20px;}
        .nextyear{  width:9px; background-position:-19px 0; right:5px;}
        .nextmonth{ width:5px; background-position:-14px 0; right:20px;}
        .calendar dd a{float: left;width: 25px;height: 22px; color:blue; overflow: hidden; text-decoration: none;
            margin: 1px 0 0 1px; text-align:center;}
        .calendar dd a.disabled{color:#999;}
        .calendar dd a.tody{ color:red; }
        .calendar dd a.on{background:blue; color:#fff;}
        .calendar dd a.live{cursor:pointer}
        .input{ border:1px solid #ccc; padding:4px; background:url(http://images.cnblogs.com/cnblogs_com/NNUF/379856/o_nextprv.png) no-repeat right -18px;}
    </style>
</head>
<body>

<form action = "${pageContext.request.contextPath}/servlet/RegisterServlet" method = "post">
    	<table>
    		<tr>
    			<td>用户名：</td>
    			<td>
    				<input type = "text" name = "username" value = ${form.username }>
    				<span>${form.errors.username }</span>
    			</td>
    		</tr>
    		
    		<tr>
    			<td>密码：</td>
    			<td>
    				<input type = "password" name = "password" value = ${form.password }>
    				<span>${form.errors.password1 }</span>
    			</td>
    			
    		</tr>
    		<tr>
    			<td>确认密码：</td>
    			<td>
    				<input type = "password" name = "password2" value = ${form.password2 }>
    				<span>${form.errors.password2 }</span>
    			</td>
    		</tr>
    		<tr>
    			<td>邮箱：</td>
    			<td>
    				<input type = "text" name = "email" value = ${form.email }>
    				<span>${form.errors.email }</span>
    			</td>
    		</tr>
    		<tr>
    			<td>您的昵称：</td>
    			<td>
    				<input type = "text" name = "nickname" value = ${form.nickname }>
    				<span>${form.errors.nickname }</span>
    			</td>
    		</tr>
    		<tr>
    			<td>您的生日：</td>
    			<td>
    				<input type="text" id="j_Date" name = "birthday" class="input" value = ${form.birthday }>
    				<span>${form.errors.birthday }</span>
    			</td>
    		</tr>
	    	<tr>
	    		<td><input type = "submit" value = "提交"></td>
	    		<td><input type = "reset" value = "重置"></td>
	    	</tr>
    	</table>
    	
		    
    </form>



<!--日历控件JS源码-->
<script>
/**
 * @namespace _CalF
 * 日历控件所用便捷函数
 * */
_CalF = {
    // 选择元素
    $:function(arg,context){
        var tagAll,n,eles=[],i,sub = arg.substring(1);
        context = context||document;
        if(typeof arg =='string'){
            switch(arg.charAt(0)){
                case '#':
                    return document.getElementById(sub);
                    break;
                case '.':
                    if(context.getElementsByClassName) return context.getElementsByClassName(sub);
                    tagAll = _CalF.$('*',context);
                    n = tagAll.length;
                    for(i = 0;i<n;i++){
                        if(tagAll[i].className.indexOf(sub) > -1) eles.push(tagAll[i]);
                    }
                    return eles;
                    break;
                default:
                    return context.getElementsByTagName(arg);
                    break;
            }
        }
    },
    // 绑定事件
    bind:function(node,type,handler){
        node.addEventListener?node.addEventListener(type, handler, false):node.attachEvent('on'+ type, handler);
    },
    // 获取元素位置
    getPos:function (node) {
        var scrollx = document.documentElement.scrollLeft || document.body.scrollLeft,
                scrollt = document.documentElement.scrollTop || document.body.scrollTop;
        pos = node.getBoundingClientRect();
        return {top:pos.top + scrollt, right:pos.right + scrollx, bottom:pos.bottom + scrollt, left:pos.left + scrollx }
    },
    // 添加样式名
    addClass:function(c,node){
        node.className = node.className + ' ' + c;
    },
    // 移除样式名
    removeClass:function(c,node){
        var reg = new RegExp("(^|\\s+)" + c + "(\\s+|$)","g");
        node.className = node.className.replace(reg, '');
    },
    // 阻止冒泡
    stopPropagation:function(event){
        event = event || window.event;
        event.stopPropagation ? event.stopPropagation() : event.cancelBubble = true;
    }
};
/**
 * @name Calender
 * @constructor
 * @created by VVG
 * @http://www.cnblogs.com/NNUF/
 * @mysheller@163.com
 * */
function Calender() {
    this.initialize.apply(this, arguments);
}
Calender.prototype = {
    constructor:Calender,
    // 模板数组
    _template :[
        '<dl>',
        '<dt class="title-date">',
        '<span class="prevyear">prevyear</span><span class="prevmonth">prevmonth</span>',
        '<span class="nextyear">nextyear</span><span class="nextmonth">nextmonth</span>',
        '</dt>',
        '<dt><strong>日</strong></dt>',
        '<dt>一</dt>',
        '<dt>二</dt>',
        '<dt>三</dt>',
        '<dt>四</dt>',
        '<dt>五</dt>',
        '<dt><strong>六</strong></dt>',
        '<dd></dd>',
        '</dl>'],
    // 初始化对象
    initialize :function (options) {
        this.id = options.id; // input的ID
        this.input = _CalF.$('#'+ this.id); // 获取INPUT元素
        this.isSelect = options.isSelect;   // 是否支持下拉SELECT选择年月，默认不显示
        this.inputEvent(); // input的事件绑定，获取焦点事件
    },
    // 创建日期最外层盒子，并设置盒子的绝对定位
    createContainer:function(){
        // 如果存在，则移除整个日期层Container
        var odiv = _CalF.$('#'+ this.id + '-date');
        if(!!odiv) odiv.parentNode.removeChild(odiv);
        var container = this.container = document.createElement('div');
        container.id = this.id + '-date';
        container.style.position = "absolute";
        container.zIndex = 999;
        // 获取input表单位置inputPos
        var input = _CalF.$('#' + this.id),
                inputPos = _CalF.getPos(input);
        // 根据input的位置设置container高度
        container.style.left = inputPos.left + 'px';
        container.style.top = inputPos.bottom - 1 + 'px';
        // 设置日期层上的单击事件，仅供阻止冒泡，用途在日期层外单击关闭日期层
        _CalF.bind(container, 'click', _CalF.stopPropagation);
        document.body.appendChild(container);
    },
    // 渲染日期
    drawDate:function (odate) { // 参数 odate 为日期对象格式
        var dateWarp, titleDate, dd, year, month, date, days, weekStart,i,l,ddHtml=[],textNode;
        var nowDate = new Date(),nowyear = nowDate.getFullYear(),nowmonth = nowDate.getMonth(),
                nowdate = nowDate.getDate();
        this.dateWarp = dateWarp = document.createElement('div');
        dateWarp.className = 'calendar';
        dateWarp.innerHTML = this._template.join('');
        this.year = year = odate.getFullYear();
        this.month = month = odate.getMonth()+1;
        this.date = date = odate.getDate();
        this.titleDate = titleDate = _CalF.$('.title-date', dateWarp)[0];
        // 是否显示SELECT
        if(this.isSelect){
            var selectHtmls =[];
            selectHtmls.push('<select>');
            for(i = 2020;i>1970;i--){
                if(i != this.year){
                    selectHtmls.push('<option value ="'+ i +'">'+ i +'</option>');
                }else{
                    selectHtmls.push('<option value ="'+ i +'" selected>'+ i +'</option>');
                }
            }
            selectHtmls.push('</select>');
            selectHtmls.push('年');
            selectHtmls.push('<select>');
            for(i = 1;i<13;i++){
                if(i != this.month){
                    selectHtmls.push('<option value ="'+ i +'">'+ i +'</option>');
                }else{
                    selectHtmls.push('<option value ="'+ i +'" selected>'+ i +'</option>');
                }
            }
            selectHtmls.push('</select>');
            selectHtmls.push('月');
            titleDate.innerHTML = selectHtmls.join('');
            // 绑定change事件
            this.selectChange();
        }else{
            textNode = document.createTextNode(year + '年' + month + '月');
            titleDate.appendChild(textNode);
            this.btnEvent();
        }
        // 获取模板中唯一的DD元素
        this.dd = dd = _CalF.$('dd',dateWarp)[0];
        // 获取本月天数
        days = new Date(year, month, 0).getDate();
        // 获取本月第一天是星期几
        weekStart = new Date(year, month-1,1).getDay();
        // 开头显示空白段
        for (i = 0; i < weekStart; i++) {
            ddHtml.push('<a>&nbsp;</a>');
        }
        // 循环显示日期
        for (i = 1; i <= days; i++) {
            if (year < nowyear) {
                ddHtml.push('<a class="live disabled">' + i + '</a>');
            } else if (year == nowyear) {
                if (month < nowmonth + 1) {
                    ddHtml.push('<a class="live disabled">' + i + '</a>');
                } else if (month == nowmonth + 1) {
                    if (i < nowdate) ddHtml.push('<a class="live disabled">' + i + '</a>');
                    if (i == nowdate) ddHtml.push('<a class="live tody">' + i + '</a>');
                    if (i > nowdate) ddHtml.push('<a class="live">' + i + '</a>');
                } else if (month > nowmonth + 1) {
                    ddHtml.push('<a class="live">' + i + '</a>');
                }
            } else if (year > nowyear) {
                ddHtml.push('<a class="live">' + i + '</a>');
            }
        }
        dd.innerHTML = ddHtml.join('');

        // 如果存在，则先移除
        this.removeDate();
        // 添加
        this.container.appendChild(dateWarp);

        //IE6 select遮罩
        var ie6  = !!window.ActiveXObject && !window.XMLHttpRequest;
        if(ie6) dateWarp.appendChild(this.createIframe());

        // A link事件绑定
        this.linkOn();
        // 区域外事件绑定
        this.outClick();
    },

    createIframe:function(){
        var myIframe =  document.createElement('iframe');
        myIframe.src = 'about:blank';
        myIframe.style.position = 'absolute';
        myIframe.style.zIndex = '-1';
        myIframe.style.left = '-1px';
        myIframe.style.top = 0;
        myIframe.style.border = 0;
        myIframe.style.filter = 'alpha(opacity= 0 )';
        myIframe.style.width = this.container.offsetWidth + 'px';
        myIframe.style.height = this.container.offsetHeight + 'px';
        return myIframe;

    },

    // SELECT CHANGE 事件
    selectChange:function(){
        var selects,yearSelect,monthSelect,that = this;
        selects = _CalF.$('select',this.titleDate);
        yearSelect = selects[0];
        monthSelect = selects[1];
        _CalF.bind(yearSelect, 'change',function(){
            var year = yearSelect.value;
            var month = monthSelect.value;
            that.drawDate(new Date(year, month-1, that.date));
        });
        _CalF.bind(monthSelect, 'change',function(){
            var year = yearSelect.value;
            var month = monthSelect.value;
            that.drawDate(new Date(year, month-1, that.date));
        })
    },
    // 移除日期DIV.calendar
    removeDate:function(){
        var odiv = _CalF.$('.calendar',this.container)[0];
        if(!!odiv) this.container.removeChild(odiv);
    },
    // 上一月，下一月按钮事件
    btnEvent:function(){
        var prevyear = _CalF.$('.prevyear',this.dateWarp)[0],
                prevmonth = _CalF.$('.prevmonth',this.dateWarp)[0],
                nextyear = _CalF.$('.nextyear',this.dateWarp)[0],
                nextmonth = _CalF.$('.nextmonth',this.dateWarp)[0],
                that = this;
        prevyear.onclick = function(){
            var idate = new Date(that.year-1, that.month-1, that.date);
            that.drawDate(idate);
        };
        prevmonth.onclick = function(){
            var idate = new Date(that.year, that.month-2,that.date);
            that.drawDate(idate);
        };
        nextyear.onclick = function(){
            var idate = new Date(that.year + 1,that.month - 1, that.date);
            that.drawDate(idate);
        };
        nextmonth.onclick = function(){
            var idate = new Date(that.year , that.month, that.date);
            that.drawDate(idate);
        }
    },
    // A 的事件
    linkOn:function(){
        var links = _CalF.$('.live',this.dd),i,l=links.length,that=this;
        for(i = 0;i<l;i++){
            links[i].index = i;
            links[i].onmouseover = function(){
                _CalF.addClass("on",links[this.index]);
            };
            links[i].onmouseout = function(){
                _CalF.removeClass("on",links[this.index]);
            };
            links[i].onclick = function(){
                that.date = this.innerHTML;
                that.input.value = that.year + '-' + that.month + '-' + that.date;
                that.removeDate();
            }
        }
    },
    // 表单的事件
    inputEvent:function(){
        var that = this;
        _CalF.bind(this.input, 'focus',function(){
            that.createContainer();
            that.drawDate(new Date());
        });
    },
    // 鼠标在对象区域外点击，移除日期层
    outClick:function(){
        var that = this;
        _CalF.bind(document, 'click',function(event){
            event = event || window.event;
            var target = event.target || event.srcElement;
            if(target == that.input)return;
            that.removeDate();
        })
    }
};
var myDate = new Calender({id:'j_Date',isSelect:!0});
</script>
</body>
</html>