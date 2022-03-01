<#import "../../mecro/base-layout.ftl" as layout>
<!DOCTYPE html>
<html>
<@layout.baseHeader "New Project">

</@layout.baseHeader>
<body class="hold-transition skin-blue sidebar-mini">
<@layout.baseWrapper>
<section class="content-header">
    <h1>유저 생성</h1>
</section>

<section class="content">
    <div class="create-user-wrap">
        <!-- Nav tabs -->
        <ul class="nav nav-pills nav-justified">
            <li class="done">1. 신규 유저 생성</li>
            <li class="active">2. 권한 그룹 설정</li>
            <li>3. 개인별 권한 설정</li>
            <li>4. 완료</li>
        </ul>
        <!-- Tab panes -->
        <div class="box box-primary box-body">
            <div class="box box-solid">
                <div class="box-header with-border"><h4>유저 정보</h4></div>
                <div class="box-body form-horizontal">
                    <div class="form-group">
                        <strong class="col-sm-2">유저 이메일</strong>
                        <div id="user-email" class="col-sm-10"></div>
                    </div>
                    <div class="form-group">
                        <strong class="col-sm-2">유저 이름</strong>
                        <div id="user-name" class="col-sm-10"></div>
                    </div>
                    <div class="form-group">
                        <strong class="col-sm-2">소속 부서</strong>
                        <div id="user-dept" class="col-sm-10"></div>
                    </div>
                    <div class="form-group">
                        <strong class="col-sm-2">개인 정보 노출 여부</strong>
                        <div id="user-privacy" class="col-sm-10"></div>
                    </div>
                </div>
            </div>

            <div id="content"></div>

            <div class="btn-area text-right">
                <button class="btn btn-default" type="button">이전</button>
                <button class="btn btn-primary" type="button" onclick="nextStep();">다음</button>
            </div>
        </div>
    </div>
</section>
</@layout.baseWrapper>
<script src="/static/plugins/datatables/jquery.dataTables.js"></script>
<script src="/static/plugins/datatables/dataTables.bootstrap.min.js"></script>
<script>
    var opt = {
        'tb_project': {
            'scrollY': '150px',
            'scrollCollapse': true,
            'columns': [
                {title: '권한 그룹명', data: 'name'},
                {title: ''}
            ],
            'columnDefs': [
                {
                    'targets': 1,
                    'data': null,
                    'defaultContent': '<input name="cbx_auth" type="checkbox" class="flat-red">'
                }
            ]
        }
    };

    var user_id = extractByWord('new-member');
    var project_id = OsoriRoute.getQuery().projectId.split(',');

    $(document).ready(function(){

        AJAX.getData(OsoriRoute.getUri('user.findOne', {userId: user_id}))
        .done(function(user){
            var user = user.result;

            $('#user-email').text(user.email);
            $('#user-name').text(user.name);
            $('#user-dept').text(user.department);
            $('#user-privacy').text(user.accessPrivacyInformation);
        });

        var row;
        var last = project_id.length-1;

        $.each(project_id, function(index, project_id) {
            if(index%3 == 0)
                row = $('<div/>', {class: 'row'});

            $.when(
                AJAX.getData(OsoriRoute.getUri('project.findOne', {id: project_id}), {}, {async:false}),
                AJAX.getData(OsoriRoute.getUri('authority.findAll', {id: project_id}), {}, {async:false})
            ).done(function(project, authority) {
                var project = project[0].result;
                var authority = authority[0].result;

                $('<div/>', {class: 'col-md-4'}).append(
                    $('<div/>', {class: 'box box-solid'}).append(
                        $('<div/>', {class: 'box-header with-border'}).append(
                            $('<h4/>', {text: project.name})
                        ),
                        $('<div/>', {class: 'box-body'}).append(
                            $('<table/>', {id: 'table_'+index, class: 'table table-bordered table-striped'})
                        )
                    )
                ).appendTo($(row));

                $(row).find('#table_'+index).DataTable(OPTION.data_table(opt.tb_project, authority));
            });

            if(index == last) {
                $(row).appendTo('#content');
            }else if(index != 0 && index%3 == 2) {
                $(row).appendTo('#content');
            }
        });

        setTimeout(function(){
            var table = $('.table').DataTable();
            $('#content input:checkbox').change(function(){
                var data = table.row($(this).parents('tr')).data();

                if($(this).is(":checked")){
                    assignAuthorityGrant(data.projectId, user_id, data.authId, this);
                }else{
                    withdrawAuthorityGrant(data.projectId, user_id, data.authId, this);
                }

            });
        }, 1000);

    });

    function assignAuthorityGrant(project_id, user_id, auth_id, chx_onoff){
        AJAX.postData(
            OsoriRoute.getUri('user.assignAuthorityGrant', {projectId: project_id, userId: user_id, authIdGroup: auth_id}),
            {'async': false}
        )
        .fail(function(){
            $(chx_onoff).prop('checked', false);
        });
    }

    function withdrawAuthorityGrant(project_id, user_id, auth_id, chx_onoff){
        AJAX.deleteData(
            OsoriRoute.getUri('user.withdrawAuthorityGrant', {projectId: project_id, userId: user_id, authIdGroup: auth_id}),
            {'async': false}
        )
        .fail(function(){
            $(chx_onoff).prop('checked', true);
        });
    }

    function nextStep(){
        AJAX.getData(OsoriRoute.getUri('user.findUsersProjects', {userId: user_id})).done(function(data){
            if(data.result.length == 0){
                alert('최소 한개이상의 권한 그룹을 선택해야합니다.');
                return false;
            }else{
                OsoriRoute.go(
                    'view.management.newMember.personalGrant',
                    {userId: user_id}, {projectId: new URI(window.location).query(true).projectId}
                );
            }

        });
    }

</script>
</body>
</html>
