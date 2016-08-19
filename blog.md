http://blog.hrendoh.com/how-to-use-terraform/

Terraformを使う機会が会ったので、概要をまとめてみました。

以下は、ほぼGETTING STARTEDを確認した内容になります

また、各リソースはデフォルトVPCに構築しています。

Contents [hide]
1 セットアップ
2 インフラを構築してみる
3 インフラの変更
4 インフラの削除
5 リソースの依存について
6 プロビジョニング
7 変数の入力について
セットアップ

INSTALL TERRAFORMの手順に従ってインストール

バイナリパッケージがあるので、DOWNLOAD TERRAFORMよりダウンロードして適当なディレクトリに解凍して、パスを通すだけ

Mac OS Xの場合は、.bash_profileあたりに設定しておく
以下 /opt/terraform_0.6.6に解凍した場合

.bash_profile
1
# Add Terraform
export PATH=$PATH:/usr/local/terraform/0.7.0

ターミナルでterraformコマンドを実行できればセットアップ完了

>>>
$ terraform
usage: terraform [--version] [--help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    destroy            Destroy Terraform-managed infrastructure
    fmt                Rewrites config files to canonical format
    get                Download and install modules for the configuration
    graph              Create a visual graph of Terraform resources
    import             Import existing infrastructure into Terraform
    init               Initializes Terraform configuration from a module
    output             Read an output from a state file
    plan               Generate and show an execution plan
    push               Upload this Terraform module to Atlas to run
    refresh            Update local state file against real resources
    remote             Configure remote state storage
    show               Inspect Terraform state or plan
    taint              Manually mark a resource for recreation
    untaint            Manually unmark a resource as tainted
    validate           Validates the Terraform files
    version            Prints the Terraform version

All other commands:
    state              Advanced state management

$ 
<<<

インフラを構築してみる

BUILD INFRASTRUCTUREの手順にそって、AWSにEC2を起動してみます

example.tf
1
2
3
4
5
6
7
8
9
10
11
provider "aws" {
    access_key = "ACCESS_KEY_HERE"
    secret_key = "SECRET_KEY_HERE"
    region = "ap-northeast-1"
}
 
resource "aws_instance" "example" {
    ami = "ami-383c1956"
    instance_type = "t2.micro"
    subnet_id = "subnet-7d83150a"
}
amiは東京リージョンのAmazon Linuxを指定
instance_typeはt2.microを指定しているので、subnet_idが必須になります。
ここでは、デフォルトVPCのサブネットの1つを指定しています

terraform planコマンドで実行計画を確認できる

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.


The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

+ aws_instance.example
    ami:                      "ami-0d729a60"
    availability_zone:        "<computed>"
    ebs_block_device.#:       "<computed>"
    ephemeral_block_device.#: "<computed>"
    instance_state:           "<computed>"
    instance_type:            "t2.nano"
    key_name:                 "<computed>"
    network_interface_id:     "<computed>"
    placement_group:          "<computed>"
    private_dns:              "<computed>"
    private_ip:               "<computed>"
    public_dns:               "<computed>"
    public_ip:                "<computed>"
    root_block_device.#:      "<computed>"
    security_groups.#:        "<computed>"
    source_dest_check:        "true"
    subnet_id:                "<computed>"
    tenancy:                  "<computed>"
    vpc_security_group_ids.#: "<computed>"

Plan: 1 to add, 0 to change, 0 to destroy.

<computed>はリソースが作成されてみないとわからない項目です

applyコマンドで適用

>>>
$ terraform apply
aws_instance.example: Creating...
  ami:                      "" => "ami-0d729a60"
  availability_zone:        "" => "<computed>"
  ebs_block_device.#:       "" => "<computed>"
  ephemeral_block_device.#: "" => "<computed>"
  instance_state:           "" => "<computed>"
  instance_type:            "" => "t2.nano"
  key_name:                 "" => "<computed>"
  network_interface_id:     "" => "<computed>"
  placement_group:          "" => "<computed>"
  private_dns:              "" => "<computed>"
  private_ip:               "" => "<computed>"
  public_dns:               "" => "<computed>"
  public_ip:                "" => "<computed>"
  root_block_device.#:      "" => "<computed>"
  security_groups.#:        "" => "<computed>"
  source_dest_check:        "" => "true"
  subnet_id:                "" => "<computed>"
  tenancy:                  "" => "<computed>"
  vpc_security_group_ids.#: "" => "<computed>"
aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Still creating... (20s elapsed)
aws_instance.example: Creation complete

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
<<<


リソース名の”example”は、terraformの中で管理されるもので、Tag Nameにはなりません。

インフラの変更

CHANGE INFRASTRUCTURE

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.

aws_instance.example: Refreshing state... (ID: i-01c22590)

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

-/+ aws_instance.example
    ami:                      "ami-0d729a60" => "ami-13be557e" (forces new resource)
    availability_zone:        "us-east-1c" => "<computed>"
    ebs_block_device.#:       "0" => "<computed>"
    ephemeral_block_device.#: "0" => "<computed>"
    instance_state:           "running" => "<computed>"
    instance_type:            "t2.nano" => "t2.nano"
    key_name:                 "" => "<computed>"
    network_interface_id:     "eni-b954dda9" => "<computed>"
    placement_group:          "" => "<computed>"
    private_dns:              "ip-172-31-51-198.ec2.internal" => "<computed>"
    private_ip:               "172.31.51.198" => "<computed>"
    public_dns:               "ec2-54-164-45-203.compute-1.amazonaws.com" => "<computed>"
    public_ip:                "54.164.45.203" => "<computed>"
    root_block_device.#:      "1" => "<computed>"
    security_groups.#:        "0" => "<computed>"
    source_dest_check:        "true" => "true"
    subnet_id:                "subnet-6e303a44" => "<computed>"
    tenancy:                  "default" => "<computed>"
    vpc_security_group_ids.#: "1" => "<computed>"


Plan: 1 to add, 0 to change, 1 to destroy.

$ terraform apply
aws_instance.example: Refreshing state... (ID: i-01c22590)
aws_instance.example: Destroying...
aws_instance.example: Still destroying... (10s elapsed)
aws_instance.example: Still destroying... (20s elapsed)
aws_instance.example: Destruction complete
aws_instance.example: Creating...
  ami:                      "" => "ami-13be557e"
  availability_zone:        "" => "<computed>"
  ebs_block_device.#:       "" => "<computed>"
  ephemeral_block_device.#: "" => "<computed>"
  instance_state:           "" => "<computed>"
  instance_type:            "" => "t2.nano"
  key_name:                 "" => "<computed>"
  network_interface_id:     "" => "<computed>"
  placement_group:          "" => "<computed>"
  private_dns:              "" => "<computed>"
  private_ip:               "" => "<computed>"
  public_dns:               "" => "<computed>"
  public_ip:                "" => "<computed>"
  root_block_device.#:      "" => "<computed>"
  security_groups.#:        "" => "<computed>"
  source_dest_check:        "" => "true"
  subnet_id:                "" => "<computed>"
  tenancy:                  "" => "<computed>"
  vpc_security_group_ids.#: "" => "<computed>"
aws_instance.example: Still creating... (5s elapsed)
aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Still creating... (15s elapsed)
aws_instance.example: Still creating... (20s elapsed)
aws_instance.example: Still creating... (25s elapsed)
aws_instance.example: Still creating... (30s elapsed)
aws_instance.example: Creation complete

Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

インフラの削除

Destroy Infrastructure

$ terraform plan -destroy
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.

aws_instance.example: Refreshing state... (ID: i-72c82fe3)

The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

- aws_instance.example


Plan: 0 to add, 0 to change, 1 to destroy.

Enter a value: でyesと入力すると実行される

$ terraform destroy
Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.example: Refreshing state... (ID: i-72c82fe3)
aws_instance.example: Destroying...
aws_instance.example: Still destroying... (10s elapsed)
aws_instance.example: Still destroying... (20s elapsed)
aws_instance.example: Still destroying... (30s elapsed)
aws_instance.example: Destruction complete

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.

リソースの依存について

Resource Dependencies
ここまで、ドキュメントにしたがって、1つのaws_instanceの作成について確認してきましたが、複数のリソースを指定した場合は、適用順序を制御する必要があります。

EC2インスタンスにElastic IPリソースを追加するようにexample.tfにaws_eipリソースを追加してみます。

example.tf
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
provider "aws" {
    access_key = "ACCESS_KEY_HERE"
    secret_key = "SECRET_KEY_HERE"
    region = "ap-northeast-1"
}
 
resource "aws_eip" "ip" {
    instance = "${aws_instance.example.id}"
    vpc = true
}
 
resource "aws_instance" "example" {
    ami = "ami-383c1956"
    instance_type = "t2.micro"
    subnet_id = "subnet-7d83150a"
    tags {
        Name = "Terraform example"
    }
}
aws_eipリソースの${aws_instance.example.id}は、後のaws_instanceリソースaws_instance.exampleを参照します。

実行計画を確認

$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but
will not be persisted to local or remote state storage.


The Terraform execution plan has been generated and is shown below.
Resources are shown in alphabetical order for quick scanning. Green resources
will be created (or destroyed and then created if an existing resource
exists), yellow resources are being changed in-place, and red resources
will be destroyed. Cyan entries are data sources to be read.

Note: You didn't specify an "-out" parameter to save this plan, so when
"apply" is called, Terraform can't guarantee this is what will execute.

+ aws_eip.ip
    allocation_id:     "<computed>"
    association_id:    "<computed>"
    domain:            "<computed>"
    instance:          "${aws_instance.example.id}"
    network_interface: "<computed>"
    private_ip:        "<computed>"
    public_ip:         "<computed>"

+ aws_instance.example
    ami:                      "ami-13be557e"
    availability_zone:        "<computed>"
    ebs_block_device.#:       "<computed>"
    ephemeral_block_device.#: "<computed>"
    instance_state:           "<computed>"
    instance_type:            "t2.nano"
    key_name:                 "<computed>"
    network_interface_id:     "<computed>"
    placement_group:          "<computed>"
    private_dns:              "<computed>"
    private_ip:               "<computed>"
    public_dns:               "<computed>"
    public_ip:                "<computed>"
    root_block_device.#:      "<computed>"
    security_groups.#:        "<computed>"
    source_dest_check:        "true"
    subnet_id:                "<computed>"
    tenancy:                  "<computed>"
    vpc_security_group_ids.#: "<computed>"


Plan: 2 to add, 0 to change, 0 to destroy.

適用時には、Elastic IPリソースに指定されているEC2インスタンスIDへの参照を検出して、暗黙的にEC2インスタンスを先に作成します。

$ terraform apply
aws_instance.example: Creating...
  ami:                      "" => "ami-13be557e"
  availability_zone:        "" => "<computed>"
  ebs_block_device.#:       "" => "<computed>"
  ephemeral_block_device.#: "" => "<computed>"
  instance_state:           "" => "<computed>"
  instance_type:            "" => "t2.nano"
  key_name:                 "" => "<computed>"
  network_interface_id:     "" => "<computed>"
  placement_group:          "" => "<computed>"
  private_dns:              "" => "<computed>"
  private_ip:               "" => "<computed>"
  public_dns:               "" => "<computed>"
  public_ip:                "" => "<computed>"
  root_block_device.#:      "" => "<computed>"
  security_groups.#:        "" => "<computed>"
  source_dest_check:        "" => "true"
  subnet_id:                "" => "<computed>"
  tenancy:                  "" => "<computed>"
  vpc_security_group_ids.#: "" => "<computed>"
aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Still creating... (20s elapsed)
aws_instance.example: Creation complete
aws_eip.ip: Creating...
  allocation_id:     "" => "<computed>"
  association_id:    "" => "<computed>"
  domain:            "" => "<computed>"
  instance:          "" => "i-452dcad4"
  network_interface: "" => "<computed>"
  private_ip:        "" => "<computed>"
  public_ip:         "" => "<computed>"
aws_eip.ip: Creation complete

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

depends_onパラメータを利用して明示的に依存するリソースを指定することもできます。


プロビジョニング

Provision

>>>
remote-execプロビジョナーを使って、Amazon Linuxに、Nginxをインストールして起動してみます。
PCでTerraformを実行しているので、インスタンス作成後にsshログインして、コマンドを実行できるようにconnectを設定します。
また、sshとWebアクセス用にインバウンド22, 80ポート、yum実行用にアウトバウンドポート全てを空けたセキュリティグループを作成しています。
<<<

まず破棄

$ terraform destroy
Do you really want to destroy?
  Terraform will delete all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.example: Refreshing state... (ID: i-452dcad4)
aws_eip.ip: Refreshing state... (ID: eipalloc-b2af878e)
aws_eip.ip: Destroying...
aws_eip.ip: Destruction complete
aws_instance.example: Destroying...
aws_instance.example: Still destroying... (10s elapsed)
aws_instance.example: Still destroying... (20s elapsed)
aws_instance.example: Still destroying... (30s elapsed)
aws_instance.example: Still destroying... (40s elapsed)
aws_instance.example: Still destroying... (50s elapsed)
aws_instance.example: Still destroying... (1m0s elapsed)
aws_instance.example: Destruction complete

Apply complete! Resources: 0 added, 0 changed, 2 destroyed.

続いてプロヴィジョン

$ terraform apply
aws_instance.example: Creating...
  ami:                      "" => "ami-13be557e"
  availability_zone:        "" => "<computed>"
  ebs_block_device.#:       "" => "<computed>"
  ephemeral_block_device.#: "" => "<computed>"
  instance_state:           "" => "<computed>"
  instance_type:            "" => "t2.nano"
  key_name:                 "" => "<computed>"
  network_interface_id:     "" => "<computed>"
  placement_group:          "" => "<computed>"
  private_dns:              "" => "<computed>"
  private_ip:               "" => "<computed>"
  public_dns:               "" => "<computed>"
  public_ip:                "" => "<computed>"
  root_block_device.#:      "" => "<computed>"
  security_groups.#:        "" => "<computed>"
  source_dest_check:        "" => "true"
  subnet_id:                "" => "<computed>"
  tenancy:                  "" => "<computed>"
  vpc_security_group_ids.#: "" => "<computed>"
aws_instance.example: Still creating... (10s elapsed)
aws_instance.example: Still creating... (20s elapsed)
aws_instance.example: Still creating... (30s elapsed)
aws_instance.example: Provisioning with 'local-exec'...
aws_instance.example (local-exec): Executing: /bin/sh -c "echo 54.167.38.210 > file.txt"
aws_instance.example: Creation complete
aws_eip.ip: Creating...
  allocation_id:     "" => "<computed>"
  association_id:    "" => "<computed>"
  domain:            "" => "<computed>"
  instance:          "" => "i-5934d3c8"
  network_interface: "" => "<computed>"
  private_ip:        "" => "<computed>"
  public_ip:         "" => "<computed>"
aws_eip.ip: Creation complete

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

$ cat file.txt
54.167.38.210

変数の入力について

Input Variables
上記までの例では、AWSのアクセスキーとシークレットキーなどをexample.tfに直接設定していましたが、
このような環境設定については、別ファイルやコマンド実行時の変数、環境変数から渡すことができます。

新たにvariables.tfを作成し、variableで変数を定義します

variables.tf
1
2
3
4
5
variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "ap-northeast-1"
}
regionはデフォルト値を設定しているので、入力がなければap-northeast-1が使われます
変数に対応したAWS providerの定義は以下のようになります

example.tf
1
2
3
4
5
variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "ap-northeast-1"
}
変数の渡し方はいくつかあります

コマンドラインオプション

$ terraform apply -var 'access_key=ACCESS_KEY_HERE' -var 'secret_key=SECRET_KEY_HERE
変数ファイル terraform.tfvars
terraform.tfvarsという名前のファイルで変数をセットすることもできます。

terraform.tfvars
1
2
access_key = "ACCESS_KEY_HERE"
secret_key = "SECRET_KEY_HERE"
terraformコマンド実行時に、カレントディレクトリのterraform.tfvarsファイルは、自動で読み込まれるので特にオプションは必要ありません。
他の名前を使いたい場合は、-var-fileオプションで指定できます。


 
環境変数
TF_VAR_<変数名>の環境変数は、変数として参照してくれます。
access_keyの場合は、TF_VAR_access_keyと指定します。

また、AWS ProviderのAWS_ACCESS_KEY_IDのようにプロバイダーによっては、特定の環境変数を読み込むものもあります。