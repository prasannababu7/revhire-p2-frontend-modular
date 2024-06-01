resource "aws_codecommit_repository" "my_frontend_repo" {
  repository_name = var.frontend-repo-name
  description     = "Repository for Project"

  tags = {
    Environment = "Dev"
    Name        = "code_commit_p2"
  }
}

#pushing files to code-commit repo
resource "null_resource" "clone_repo" {
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p C:/Users/PC/Desktop/Terraform-new/revhire-frontend-repo
      git clone ${aws_codecommit_repository.my_frontend_repo.clone_url_http} C:/Users/PC/Desktop/Terraform-new/revhire-frontend-repo
      cp -r C:/Users/PC/Desktop/Terraform-new/revhire-frontend/* C:/Users/PC/Desktop/Terraform-new/revhire-frontend-repo
      cp -r C:/Users/PC/Desktop/Terraform-new/revhire-frontend/.* C:/Users/PC/Desktop/Terraform-new/revhire-frontend-repo
      cd C:/Users/PC/Desktop/Terraform-new/revhire-frontend-repo
      git add .
      git commit -m "Initial commit"
      git push -u origin master
    EOT
    interpreter = ["C:\\Program Files\\Git\\bin\\bash.exe", "-c"]
  }

  depends_on = [aws_codecommit_repository.my_frontend_repo]
  triggers = {
    always_run = timestamp()
  }
}


module "s3" {
  source = "./modules/s3"
  frontend-bucket-name = var.frontend-bucket-name
}

module "codebuild" {
  source = "./modules/codebuild"
  frontend-repo-name = var.frontend-repo-name
  frontend-bucket-name = var.frontend-bucket-name
}