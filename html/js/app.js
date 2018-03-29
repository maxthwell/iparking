var loraserver = angular.module('loraserver', [
    'ngRoute',
    'loraserverControllers'
    ]);
function popInfo($ele){
    $ele.fadeIn();
    setTimeout(function () {
        $ele.fadeOut();
    }, 1500);
}
var errorArr = [
    "ERROR_NONE",
    "ERROR_APPLICATION_CREATE_FAIL",
    "ERROR_APPLICATION_GETLIST_FAIL",
    "ERROR_APPLICATION_EUI_INVALID",
    "ERROR_APPLICATION_NAME_INVALID",
    "ERROR_APPLICATION_EUI_NO_EXISTS",
    "ERROR_APPLICATION_DELETE_FAIL",
    "ERROR_APPLICATION_GET_FAIL",
    "ERROR_APPLICATION_UPDATE_FAIL",
    "ERROR_CHANNELLIST_NAME_INVALID",
    "ERROR_CHANNELLIST_CREATE_FAIL",
    "ERROR_CHANNELLIST_ID_INVALID",
    "ERROR_CHANNELLIST_DELETE_FAIL",
    "ERROR_CHANNELLIST_ID_NO_EXISTS",
    "ERROR_CHANNELLIST_GET_FAIL",
    "ERROR_CHANNELLIST_GETLIST_FAIL",
    "ERROR_CHANNELLIST_UPDATE_FAIL",
    "ERROR_CHANNEL_CHANNEL_INVALID",
    "ERROR_CHANNEL_FREQUENCY_INVALID",
    "ERROR_CHANNEL_CREATE_FAIL",
    "ERROR_CHANNEL_ID_INVALID",
    "ERROR_CHANNEL_ID_NO_EXISTS",
    "ERROR_CHANNEL_DELETE_FAIL",
    "ERROR_CHANNEL_GET_FAIL",
    "ERROR_CHANNEL_EMPTY_IN_CHANNELLIST",
    "ERROR_CHANNEL_GET_CHANNELLIST_FAIL",
    "ERROR_GATEWAY_CREATE_FAIL",
    "ERROR_GATEWAY_ID_INVALID",
    "ERROR_GATEWAY_NAME_INVALID",
    "ERROR_GATEWAY_ID_NO_EXISTS",
    "ERROR_GATEWAY_DELETE_FAIL",
    "ERROR_GATEWAY_GET_FAIL",
    "ERROR_GATEWAY_GETLIST_FAIL",
    "ERROR_GATEWAY_UPDATE_FAIL",
    "ERROR_GATEWAY_GET_ALL_NUMBER_FAIL",
    "ERROR_NODE_DEVEUI_INVALID",
    "ERROR_NODE_APPKEY_INVALID",
    "ERROR_NODE_RX_DELAY_INVALID",
    "ERROR_NODE_RX1_DR_OFFSET_INVALID",
    "ERROR_NODE_CREATE_FAIL",
    "ERROR_NODE_DEVEUI_NO_EXISTS",
    "ERROR_NODE_DELETE_FAIL",
    "ERROR_NODE_GET_FAIL",
    "ERROR_NODE_GETLIST_FAIL",
    "ERROR_NODE_UPDATE_FAIL",
    "ERROR_NODE_GETDATALIST_FAIL",
    "ERROR_NODE_GETDATALISTFORAPPEUI_FAIL",
    "ERROR_NODE_GETLISTFORAPPEUI_FAIL",
    "ERROR_NODE_GETNODEDATALIST_FAIL",
    "ERROR_NODE_GET_ALL_FROM_APPLY_FAIL",
    "ERROR_NODE_APPLY_TIME_INVALID",
    "ERROR_NODE_GET_ALL_FROM_APPLY_TIME_FAIL",
    "ERROR_NODE_GET_ALL_NUMBER_FAIL",
    "ERROR_NODE_GET_ALL_DATA_DATE_NUMBER_EMPTY",
    "ERROR_NODE_GET_ALL_DATA_DATE_NUMBER_FAIL",
    "ERROR_USER_REG_MAIL_ILLEGAL",
    "ERROR_USER_REG_MAIL_EXIST",
    "ERROR_USER_CREATE_FAIL",
    "ERROR_USER_ID_INVALID",
    "ERROR_GET_REG_APPLY_LIST_FAIL",
    "ERROR_REG_APPLY_APPROVE_USERID_DEALED_OR_NO_EXSISTS",
    "ERROR_REG_APPLY_APPROVE_FAIL",
    "ERROR_LOGIN_USERID_OR_PASSWD_WRONG",
    "ERROR_LOGIN_FAILED",
    "ERROR_UPDATE_APPSEC_USERID_NO_EXSISTS",
    "ERROR_UPDATE_APPSEC_FAIL",
    "ERROR_DEV_ADDR_APPLYING_NOT_ALLOWED_CAUSE_ALREADY_ONE_IN_PROGRESS",
    "ERROR_DEV_ADDR_APPLYING_NOT_ALLOWED_CAUSE_APPEUI_USERID_MISMATCH",
    "ERROR_DEV_ADDR_APPLYING_FAIL",
    "ERROR_DEVADDR_APPLY_NO_EXSISTS",
    "ERROR_DEVADDR_APPLY_DELETE_FAIL",
    "ERROR_DEVADDR_APPLY_APPROVE_FAIL",
    "ERROR_DEVADDR_APPLY_HAS_BEEN_DEALED_OR_NO_EXIST",
    "ERROR_NO_TOKEN",
    "ERROR_TOKEN_EXPIRED",
    "ERROR_TOKEN_CHECK_WRONG",
    "ERROR_ROOT_CHECK_WRONG",
    "ERROR_APPSEC_WRONG_NO_EXIST",
    "ERROR_APPSEC_WRONG_CHECK_FAILED",
    "ERROR_CMD_NO_EXIST",
]
loraserver.config(["$provide", function($provide) {
    return $provide.decorator('$http', ['$delegate', function($delegate) {
        $delegate.rpc = function(method, parameters) {
            var data = {"params": parameters};
            return $delegate.post('/api/'+method, data, {'headers':{'Content-Type': 'application/json'}});
        };
        return $delegate;
        }]);
    }]);

loraserver.config(['$routeProvider', function($routeProvider) {
        $routeProvider.
            when('/gateways', {
                templateUrl: 'partials/gateways.html',
                controller: 'GatewayListCtrl'
            }).
            when('/data', {
                templateUrl: 'partials/data.html',
                controller: 'DataListCtrl'
            }).
            when('/applications', {
                templateUrl: 'partials/applications.html',
                controller: 'ApplicationListCtrl'
            }).
            when('/applications/:application', {
                templateUrl: 'partials/application.html',
                controller: 'ApplicationCtrl'
            }).
            when('/channels', {
                templateUrl: 'partials/channel_lists.html',
                controller: 'ChannelListListCtrl'
            }).
            when('/channels/:list', {
                templateUrl: 'partials/channel_list.html',
                controller: 'ChannelListCtrl'
            }).
            when('/api', {
                templateUrl: 'partials/api.html',
                controller: 'APICtrl'
            }).
            when('/home', {
                templateUrl: 'partials/home.html',
                controller: 'HomeCtrl'
            }).
            otherwise({
                redirectTo: '/home'
            });
        }]);

var loraserverControllers = angular.module('loraserverControllers', []);

loraserverControllers.controller('HomeCtrl',function($scope,$http,$routeParams,$route){
        $scope.page = 'home';
        $http.rpc('Gateway_GetAllNumber', {}).success(function(data) {
            $scope.GYtotal = data.result.total;
        });
        $http.rpc('Node_GetAllNumber', {}).success(function(data) {
            $scope.activeNum = data.result.activeNum;
            $scope.approveNum = data.result.approveNum;
        });
        $http.rpc('Node_GetAllTodayDataNumber', {}).success(function(data) {
            $scope.dataUpCount = data.result.dataUpCount;
            $scope.dataDownCount = data.result.dataDownCount;
            $scope.dataInNodeCount = data.result.dataInNodeCount;
            $scope.loss = $scope.dataInNodeCount - $scope.dataUpCount;
        });
        $http.rpc('Node_GetDataList', {'limit': 10, 'offset': 0,'userId':1}).success(function(data) {
            $scope.datalist = data.result;
        });
});
// display rpc docs
loraserverControllers.controller('APICtrl',function ($scope, $http) {
        $scope.page = 'api';
        $http.get('/rpc').success(function(data) {
            $scope.apis = data;
        });
    });

// manage gateways
loraserverControllers.controller('GatewayListCtrl',['$scope', '$http', '$routeParams', '$route',function ($scope, $http, $routeParams, $route) {
        $scope.page = 'gateways';
        $http.rpc('Gateway_GetList', {'limit': 10, 'offset': 0}).success(function(data) {
                $scope.gateways = data.result;
        });
        $scope.create_ = function(){
            $('#createModal').modal();
        };
        $scope.createGateway = function(gateway) {
            if(!gateway) {
                popInfo($('.alert-warning'));
            } else {
                $http.rpc('Gateway_Create', gateway).success(function(data) {
                    if (data.error == 0) {
                        $('#createModal').modal('hide');
                        popInfo($('.alert-success'));
                    } else{
                        $scope.error = errorArr[data.error];
                        $('#nameId').val("").focus();
                    }
                });
            }
        };

        $scope.editGateway = function(gateway) {
            $http.rpc('Gateway_Get', gateway.id).success(function(data) {
                $scope.gateway = data.result;
                $('#editGatewayModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            });
        };

        $scope.updateGateway = function(gateway) {
            $http.rpc('Gateway_Update', gateway).success(function(data) {
                if (data.error == 0) {
                    popInfo($('.alert-success'));
                    $('#editGatewayModal').modal('hide').on('hidden.bs.modal',function() {
                        $route.reload();
                    });
                } else {
                    $scope.error = errorArr[data.error];
                };

            });
        };

        $scope.deleteGateway = function(gateway) {
            if (confirm('Are you sure you want to delete ' + gateway.id + '?')) {
                $http.rpc('Gateway_Delete', gateway.id).success(function(data) {
                    if (data.error == 0) {
                        popInfo($('.alert-success'));
                        $route.reload();
                    } else{
                        popInfo($('.alert-danger'));
                    }

                });
            }
        };
    }]);

// manage applications
loraserverControllers.controller('ApplicationListCtrl', ['$scope', '$http', '$routeParams', '$route',
    function ($scope, $http, $routeParams, $route) {
        $scope.page = 'applications';
        $http.rpc('Application_GetList', {'limit': 10, 'offset': 0,userId:1}).success(function(data) {
                $scope.apps = data.result;
        });
        $scope.pop = function(){
            $('#createModal').modal();
        };
        $scope.createApplication = function(app) {
            if(app==null) {
                popInfo($('.alert-warning'))
            } else {
                $http.rpc('Application_Create',app).success(function(data) {
                    if (data.error = 0) {
                        $('#createModal').on('hidden.bs.modal', function(){
                            popInfo($('.alert-success'));
                        })
                    }else {
                        $scope.error = errorArr[data.error];
                    }
                });
            }
        };

        $scope.editApplication = function(app) {
            $http.rpc('Application_Get', app.appEUI).success(function(data) {
                $scope.app = data.result;
                $('#editApplicationModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            });
        };

        $scope.updateApplication = function(app) {
            $http.rpc('Application_Update', app).success(function(data) {
                if (data.error == 0) {
                    popInfo($('.alert-success'));
                    $('#editApplicationModal').modal('hide').on('hidden.bs.modal', function() {
                        $route.reload();
                    });
                } else{
                    $scope.error = errorArr[data.error];
                }

            });
        };

        $scope.deleteApplication = function(app) {
            if (confirm('Are you sure you want to delete ' + app.appEUI + '?')) {
                $http.rpc('Application_Delete', app.appEUI).success(function(data) {
                    if (data.error != 0) {
                        alert(data.error);
                    }
                    $route.reload();
                });
            }
        };
    }]);

loraserverControllers.controller('DataListCtrl',function ($scope, $http, $routeParams, $route) {
        $scope.page = 'data';
        $http.rpc('Node_GetDataList', {'limit': 10, 'offset': 0,'userId':1}).success(function(data) {
                $scope.datalist = data.result;
        });

    });
loraserverControllers.filter('cutTime',function(){
    return function(input){
        var time = input.split(' '),
            t = time[1];
        var b = t.lastIndexOf('.'),
            c = t.substr(0,b+2);
        return time[0]+'\n'+c;
    }
});
// manage nodes
loraserverControllers.controller('ApplicationCtrl', ['$scope', '$http', '$routeParams', '$route',
    function ($scope, $http, $routeParams, $route) {
        $scope.page = 'applications';

        $http.rpc('Node_GetDataListForAppEUI', {'appEUI': $routeParams.application, 'limit': 10, 'offset': 0,'userId':1}).success(function(data) {
            $scope.nodes = data.result;
        });

        /*$http.rpc('Application_GetList', $routeParams.application).success(function(data) {
            $scope.application = data.result;
        });
*/

        /*$http.rpc('ChannelList.GetList', {'limit': 9999, 'offset': 0}).success(function(data) {
            $scope.channelLists = data.result;
        });*/

        $scope.createNode = function(node) {
            if (node == null) {
                $('#createNodeModal').modal().on('hidden.bs.modal', function(){
                    $route.reload();
                });
            } else {
                node.appEUI = $routeParams.application;
                $http.rpc('Node.Create', node).success(function(data) {
                    if (data.error == null) {
                        $('#createNodeModal').modal('hide');
                    }
                    $scope.error = data.error;
                });
            }
        };

        $scope.editNode = function(node) {
            $http.rpc('Node_Get', node.devEUI).success(function(data) {
                $scope.node = data.result;
                $('#editNodeModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            });
        };

        $scope.updateNode = function(node) {
            $http.rpc('Node.Update', node).success(function(data) {
                if (data.error == null) {
                    $('#editNodeModal').modal('hide');
                }
                $scope.error = data.error;
            });
        };

        $scope.deleteNode = function(node) {
            if (confirm('Are you sure you want to delete ' + node.devEUI + '?')) {
                $http.rpc('Node.Delete', node.devEUI).success(function(data) {
                   if (data.error != null) {
                        alert(data.error);
                    }
                    $route.reload();
                });
            }
        };

        $scope.editNodeSession = function(node) {
            $http.rpc('NodeSession.GetByDevEUI', node.devEUI).success(function(data) {
                $scope.ns = data.result;
                if ($scope.ns == null) {
                    $scope.ns = {
                        devEUI: node.devEUI,
                        appEUI: node.appEUI,
                        fCntUp: 0,
                        fCntDown: 0
                    };
                }
                $('#nodeSessionModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            });
        };

        $scope.updateNodeSession = function(ns) {
            $http.rpc('NodeSession.Update', ns).success(function(data) {
               if (data.error == null) {
                    $('#nodeSessionModal').modal('hide');
                }
                $scope.error = errorArr[data.error];
            });
        };

        $scope.getRandomDevAddr = function(ns) {
            $http.rpc('NodeSession.GetRandomDevAddr', null).success(function(data) {
                ns.devAddr = data.result;
                $scope.error = errorArr[data.error];
            });
        };
    }]);

// manage channel lists
loraserverControllers.controller('ChannelListListCtrl', ['$scope', '$http', '$routeParams', '$route',
    function ($scope, $http, $routeParams, $route) {
        $scope.page = 'channels';
        $http.rpc('ChannelList.GetList', {'limit': 9999, 'offset': 0}).success(function(data) {
            $scope.channelLists = data.result;
        });

        $scope.createList = function(cl) {
            if (cl == null) {
                $('#createChannelListModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            } else {
                $http.rpc('ChannelList.Create', cl).success(function(data) {
                    if (data.error == null) {
                        $('#createChannelListModal').modal('hide');
                    }
                    $scope.error = data.error;
                });
            }
        };

        $scope.editList = function(cl) {
            $http.rpc('ChannelList.Get', cl.id).success(function(data) {
                $scope.channelList = data.result;
                $('#editChannelListModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            });
        };

        $scope.updateList = function(cl) {
            $http.rpc('ChannelList.Update', cl).success(function(data) {
                if (data.error == null) {
                    $('#editChannelListModal').modal('hide');
                }
                $scope.error = data.error;
            });
        };

        $scope.deleteList = function(cl) {
            if (confirm('Are you sure you want to delete ' + cl.name + '?')) {
                $http.rpc('ChannelList.Delete', cl.id).success(function(data) {
                    if (data.error != null) {
                        alert(data.error);
                    }
                    $route.reload();
                });
            }
        };
    }]);

// manage channel list
loraserverControllers.controller('ChannelListCtrl', ['$scope', '$http', '$routeParams', '$route',
    function ($scope, $http, $routeParams, $route) {
        $scope.page = 'channels';
        $http.rpc('ChannelList.Get', parseInt($routeParams.list)).success(function(data) {
            $scope.channelList = data.result;
        });
        $http.rpc('Channel.GetForChannelList', parseInt($routeParams.list)).success(function(data) {
            $scope.channels = data.result;
        });

        $scope.createChannel = function(c) {
            if (c == null) {
                $('#createChannelModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            } else {
                c.channelListID = $scope.channelList.id;
                $http.rpc('Channel.Create', c).success(function(data) {
                    if (data.error == null) {
                        $('#createChannelModal').modal('hide');
                    }
                    $scope.error = data.error;
                });
            }
        };

        $scope.editChannel = function(c) {
            $http.rpc('Channel.Get', c.id).success(function(data) {
                $scope.channel = data.result;
                $('#editChannelModal').modal().on('hidden.bs.modal', function() {
                    $route.reload();
                });
            });
        };

        $scope.updateChannel = function(c) {
            $http.rpc('Channel.Update', c).success(function(data) {
                if (data.error == null) {
                    $('#editChannelModal').modal('hide');
                }
                $scope.error = data.error;
            });
        };

        $scope.deleteChannel = function(c) {
            if (confirm('Are you sure you want to delete channel # ' + c.channel + '?')) {
                $http.rpc('Channel.Delete', c.id).success(function(data) {
                    if (data.error != null) {
                        alert(data.error);
                    }
                    $route.reload();
                });
            }
        };
    }]);