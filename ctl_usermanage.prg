DEFINE CLASS ctl_usermanage as Session


    PROCEDURE changepwd
         **���ձ����ݵ�ֵ
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
         ERROR '�����޸�ʧ��'
    ENDPROC
    
    **2019.11.8����md5
    PROCEDURE changepwd1108
         **���ձ����ݵ�ֵ
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
         ERROR '�����޸�ʧ��'
    ENDPROC
    
    **ע�����û�
    PROCEDURE register
      **���ձ����ݵ�ֵ
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
         ERROR '�û�ע��ʧ��'
    endproc

ENDDEFINE
