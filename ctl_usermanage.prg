DEFINE CLASS ctl_usermanage as Session


    PROCEDURE changepwd
         **接收表单传递的值
         cUser = HttpQueryParams("username")
         cnewpwd = HttpQueryParams("newpwd")
         cconpwd = HttpQueryParams("conpwd")

         TEXT TO lcSql NOSHOW textmerge
             UPDATE users SET password = '<<cnewpwd>>' WHERE username = '<<cUser>>'
         ENDTEXT 
         oDbHelper = NEWOBJECT("MsSqlHelper","MsSqlHelper.prg")
         nRow = oDbHelper.ExecuteSql(lcSql)         
         IF nRow > 0
             RETURN [{"errno":0,"errmsg":"ok","success":true}]
         ENDIF      
         ERROR '密码修改失败'
    ENDPROC
    
    **2019.11.8增加md5
    PROCEDURE changepwd1108
         **接收表单传递的值
         cUser = HttpQueryParams("username")
         cnewpwd = HttpQueryParams("newpwd")
         cnewpwd = MD5String(cnewpwd)
         cconpwd = HttpQueryParams("conpwd")

         TEXT TO lcSql NOSHOW textmerge
             UPDATE users SET password = '<<cnewpwd>>' WHERE username = '<<cUser>>'
         ENDTEXT 
         oDbHelper = NEWOBJECT("MsSqlHelper","MsSqlHelper.prg")
         nRow = oDbHelper.ExecuteSql(lcSql)         
         IF nRow > 0
             RETURN [{"errno":0,"errmsg":"ok","success":true}]
         ENDIF      
         ERROR '密码修改失败'
    ENDPROC
    
    **注册新用户
    PROCEDURE register
      **接收表单传递的值
         cUser = HttpQueryParams("username")
         cpwd = MD5String(HttpQueryParams("pwd"))         

         TEXT TO lcSql NOSHOW textmerge
             INSERT INTO  users  (username,password) VALUES ('<<cUser>>','<<cPwd>>')
         ENDTEXT 
         oDbHelper = NEWOBJECT("MsSqlHelper","MsSqlHelper.prg")
         nRow = oDbHelper.SqlQuery(lcSql,"users")         
         IF nRow > 0
             RETURN [{"errno":0,"errmsg":"ok","success":true}]
         ENDIF      
         ERROR '用户注册失败'
    endproc

ENDDEFINE
