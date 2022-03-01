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
            <li class="done">2. 권한 그룹 설정</li>
            <li class="done">3. 개인별 권한 설정</li>
            <li class="active">4. 완료</li>
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
                <button class="btn btn-primary" type="button" onclick="complete();">완료</button>
            </div>
        </div>
    </div>
</section>
</@layout.baseWrapper>
<script src="/static/plugins/datatables/jquery.dataTables.js"></script>
<script src="/static/plugins/datatables/dataTables.bootstrap.min.js"></script>
<script>
    var opt = {
        'tb_group': {
            'scrollY': '150px',
            'scrollCollapse': true,
            'columns': [
                {title: '권한 그룹명', data: 'name'},
            ]
        },
        'tb_personal': {
            'scrollY': '150px',
            'scrollCollapse': true,
            'columns': [
                {title: '타입', data: 'type'},
                {title: '메뉴명', data: 'name'},
                {title: 'URL 경로', data: 'fullUrl'}
            ]
        }
    };

    var user_id = extractByWord('new-member');

    $(document).ready(function() {
        AJAX.getData(OsoriRoute.getUri('user.findOne', {userId: user_id}))
        .done(function (user) {
            var user = user.result;

            $('#user-email').text(user.email);
            $('#user-name').text(user.name);
            $('#user-dept').text(user.department);
            $('#user-privacy').text(user.accessPrivacyInformation);
        });

        var box;
        AJAX.getData(OsoriRoute.getUri('user.findUsersProjects', {userId: user_id}))
        .done(function(data){

            $.each(data.result, function(index, project) {
                box = $('<div/>', {class: 'box box-solid'});

                AJAX.getData(
                    OsoriRoute.getUri('user.findGrantsForUser', {userId: user_id, projectId: project.id})
                    , {}
                    , {async: false}
                ).done(function (data) {
                    var group = data.result.authorityDefinitions;
                    var personal = data.result.menuNavigations;

                    $('<div/>', {class: 'box-header with-border'}).append(
                        $('<h4/>', {text: project.name}),
                        $('<div/>', {class: 'box-body'}).append(
                            $('<div/>', {class: 'col-sm-5'}).append(
                                $('<h4/>', {text: '권한 그룹'}),
                                $('<table/>', {id: 'tb_group_'+index, class: 'table table-bordered table-striped'})
                            ),
                            $('<div/>', {class: 'col-sm-7'}).append(
                                $('<h4/>', {text: '개별 권한'}),
                                $('<table/>', {id: 'tb_personal_'+index, class: 'table table-bordered table-striped'})
                            )
                        )
                    ).appendTo($(box));

                    $(box).find('#tb_group_'+index).DataTable(OPTION.data_table(opt.tb_group, group));
                    $(box).find('#tb_personal_'+index).DataTable(OPTION.data_table(opt.tb_personal, personal));
                });

                $(box).appendTo('#content');
            });
        });
    });

    function complete(){
        OsoriRoute.go('view.management.members');
    }

</script>
</body>
</html>
