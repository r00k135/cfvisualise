<?xml version="1.0" encoding="UTF-8"?>
<!-- Written By Chris Elleman (@chris_elleman) -->
<!-- ToDo List -->
<!-- ElastiCache -->
<!-- IAM -->
<!-- URL References-->
<!-- Pass in References in GET string-->
<!-- Sorting ASGs and Backend LBs in VPC -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://aws.amazon.com/CFvisuliser/functions" version="1.0">
	<xsl:variable name="vpcRefName" />
	<xsl:template match="/">
		<div class="topSummary">
			<h2>Stack Description</h2>
			<p>
				<xsl:value-of select="fn:functions/cloudformation/Description" />
			</p>
		</div>
		<div class="aws">
			<img src="icons/AWS_Simple_Icons_svg_eps/Non-Service%20Specific/SVG/Non-Service%20Specific%20copy_%20AWS%20Cloud.svg" class="topLeftImage" alt="AWS" />
			<xsl:apply-templates select="fn:functions/cloudformation/Resources" />
			<div class="aws-footer">AWS Cloud</div>
		</div>
	</xsl:template>
	
	<xsl:template match="fn:functions/cloudformation/Resources">
		<!-- Global Services: IAM, Route53, CloudFront -->
		<div class="global">
			<xsl:for-each select="*/Type[text() = 'AWS::CloudFront::Distribution']/..">
				<div class="global-service">
					<xsl:variable name="CFRef">
						<xsl:value-of select="name(.)" />
					</xsl:variable>
					<img src="icons/AWS_Simple_Icons_svg_eps/Storage%20&amp;%20Content%20Delivery/SVG/Storage%20&amp;%20Content%20Delivery_Amazon%20CloudFront%20Download%20Distribution.svg" alt="CloudFront" id="{$CFRef}" />
					<br/>
					CloudFront
					<br />
					<xsl:value-of select="$CFRef" />
				</div>
			</xsl:for-each>
			<xsl:for-each select="*/Type[text() = 'AWS::Route53::RecordSet']/..">
				<div class="global-service">
					<xsl:variable name="R53Ref">
						<xsl:value-of select="name(.)" />
					</xsl:variable>
					<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20Route%2053%20Hosted%20Zone.svg" alt="Route53" id="{$R53Ref}" />
					<br />
					Route53
					<br />
					<xsl:value-of select="$R53Ref" />
				</div>
			</xsl:for-each>
		</div>
		<!-- Regional Services - Outside of VPC -->
		<div class="regional">
			<!-- S3 -->
			<xsl:for-each select="*/Type[text() = 'AWS::S3::Bucket']/..">
				<xsl:variable name="S3Bucket">
					<xsl:value-of select="name(.)" />
				</xsl:variable>
				<div class="regional-service">
					<img src="icons/AWS_Simple_Icons_svg_eps/Storage%20&amp;%20Content%20Delivery/SVG/Storage%20&amp;%20Content%20Delivery_Amazon%20S3%20Bucket.svg" alt="S3 Bucket" id="{$S3Bucket}" />
					<br />
					S3 Bucket
					<br />
					<xsl:value-of select="$S3Bucket" />
				</div>
			</xsl:for-each>
			<!-- DynamoDB -->
			<xsl:for-each select="*/Type[text() = 'AWS::DynamoDB::Table']/..">
				<xsl:variable name="DynamoTableRef">
					<xsl:value-of select="name(.)" />
				</xsl:variable>
				<div class="regional-service">
					<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_DynamoDB.svg" alt="DynamoDB" id="{$DynamoTableRef}" />
					<br />
					DynamoDB Table 
					<br />
					<xsl:value-of select="$DynamoTableRef" />
				</div>
			</xsl:for-each>
			<!-- SQS -->
			<xsl:for-each select="*/Type[text() = 'AWS::SQS::Queue']/..">
				<xsl:variable name="SQSRef">
					<xsl:value-of select="name(.)" />
				</xsl:variable>
				<div class="regional-service">
					<img src="icons/AWS_Simple_Icons_svg_eps/App%20Services/SVG/App%20Services%20copy_Amazon%20SQS%20Queue.svg" alt="DynamoDB" id="{$SQSRef}" />
					<br />
					SQS
					<br />
					<xsl:value-of select="$SQSRef" />
				</div>
			</xsl:for-each>
			<!-- VPC or Novice/EC2 Classic/VPC By Default -->
			<xsl:choose>
				<xsl:when test="*/Type[text() = 'AWS::EC2::VPC']">
					<xsl:call-template name="vpc-template" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="novice-template" />
				</xsl:otherwise>
			</xsl:choose>
			<div class="region-footer">Region</div>
		</div>
	</xsl:template>

	<xsl:template name="vpc-template">
		<!-- Show VPCs -->
		<xsl:for-each select="*/Type[text() = 'AWS::EC2::VPC']/..">
			<xsl:variable name="vpcRefName">
				<xsl:value-of select="name(.)" />
			</xsl:variable>
			<div class="vpc">
				<img src="icons/AWS_Simple_Icons_svg_eps/Non-Service%20Specific/SVG/Non-Service%20Specific%20copy_Virtual%20Private%20CLoud%20.svg" class="topLeftImage" alt="VPC" />
				<br />
				<!-- Internet Gateway and Related Route and Table-->
				<xsl:variable name="vpcGatewayAttach">
					<xsl:value-of select="name(../*/Type[text() = 'AWS::EC2::VPCGatewayAttachment']/../Properties/VpcId/Ref[text() = $vpcRefName]/../../..)" />
				</xsl:variable>
				<xsl:variable name="vpcInetGatewayRef">
					<xsl:value-of select="../*[name() = $vpcGatewayAttach]/Properties/InternetGatewayId/Ref" />
				</xsl:variable>
				<xsl:variable name="vpcPublicRouteTableRef">
					<xsl:value-of select="../*/Type[text() = 'AWS::EC2::Route']/../Properties[DestinationCidrBlock = '0.0.0.0/0' and GatewayId/Ref = $vpcInetGatewayRef]/RouteTableId/Ref" />
				</xsl:variable>
				<!-- Internet Gateway -->
				<xsl:for-each select="../*/Type[text() = 'AWS::EC2::VPCGatewayAttachment']/../Properties/VpcId/Ref[text() = $vpcRefName]">
					<div class="EC2-InternetGateway">
						<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20VPC%20Internet%20Gateway.svg" alt="IGW" id="{$vpcInetGatewayRef}" />
						<br />
						Internet Gateway:
						<xsl:value-of select="$vpcInetGatewayRef" />
					</div>
				</xsl:for-each>
				<!-- Count VPC Public Subnets Uniquely -->
				<xsl:variable name="publicSubnetCount">
					<xsl:value-of select="count(../*/Type[text() = 'AWS::EC2::SubnetRouteTableAssociation']/../Properties/RouteTableId/Ref[text() = $vpcPublicRouteTableRef]/../../SubnetId/Ref[not(.=preceding-sibling::item)])" />
				</xsl:variable>
					<xsl:if test="$publicSubnetCount &gt; 0">
						<div class="VPCsubnets">
							<!-- Divide Width By Number of Subnets into Integer -->
							<xsl:variable name="publicSubnetDisplayWidthPercent"><xsl:value-of select="round(100 div $publicSubnetCount) - 3" /></xsl:variable>
							<!-- Find VPC Public Subnets and Display, Assume one a single top layer-->
							<xsl:for-each select="../*/Type[text() = 'AWS::EC2::SubnetRouteTableAssociation']/../Properties/RouteTableId/Ref[text() = $vpcPublicRouteTableRef]/../../SubnetId/Ref">
								<xsl:variable name="subnetRef">
									<xsl:value-of select="." />
								</xsl:variable>
								<div class="EC2-Subnet" style="width:{$publicSubnetDisplayWidthPercent}%;">
									<img src="icons/VPC_Subnet.svg" alt="Subnet" id="{$subnetRef}" class="topLeftImage" />
									<!-- Public ELBs -->
									<xsl:for-each select="/*//Type[text() = 'AWS::ElasticLoadBalancing::LoadBalancer']/../Properties/Subnets/Ref[text() = $subnetRef]/../../..">
										<xsl:variable name="publicELBref">
											<xsl:value-of select="name(.)" />
										</xsl:variable>
										<div class="ELB-Public">
											<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Elastic%20Load%20Balancing.svg" alt="ELB" id="{$publicELBref}" />
											<br />
											<xsl:value-of select="$publicELBref" />
										</div>
									</xsl:for-each>
									<!-- AS Groups -->
									<xsl:for-each select="/*//Type[text() = 'AWS::AutoScaling::AutoScalingGroup']/../Properties/VPCZoneIdentifier//Ref[text() = $subnetRef]/../../..">
										<xsl:variable name="publicASref">
											<xsl:value-of select="name(.)" />
										</xsl:variable>
										<div class="AS-ASG">
											<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Auto%20Scaling.svg" alt="AS" id="{$publicASref}" class="AS-ASG-IMAGE"/>
											<br />
											<xsl:value-of select="$publicASref" />
										</div>
									</xsl:for-each>
									<!-- Instances -->
									<div class="EC2-Instances">
										<xsl:for-each select="/*//Type[text() = 'AWS::EC2::Instance']/../Properties/SubnetId//Ref[text() = $subnetRef]/../../..">
											<xsl:variable name="publicInstance">
												<xsl:value-of select="name(.)" />
											</xsl:variable>
											<div class="EC2-Instance">
												<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instance.svg" alt="EC2" id="{$publicInstance}"/>
												<!-- Look for EIP -->
												<xsl:for-each select="/*//Type[text() = 'AWS::EC2::EIP']/../Properties/InstanceId//Ref[text() = $publicInstance]/../../..">
													<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Elastic%20IP.svg" alt="EIP" class="EIP"/>
												</xsl:for-each>
												<br /><xsl:value-of select="$publicInstance" />
											</div>
										</xsl:for-each>
									</div>
									<!-- RDS Instances -->
									<div class="RDS-Instances">
										<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBSubnetGroup']/../Properties/SubnetIds//Ref[text() = $subnetRef]/../../..">
											<xsl:variable name="publicDBsubnetGroup">
												<xsl:value-of select="name(.)" />
											</xsl:variable>
											<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBInstance']/../Properties/DBSubnetGroupName//Ref[text() = $publicDBsubnetGroup]/../../..">
												<xsl:variable name="publicDBinstance">
													<xsl:value-of select="name(.)" />
												</xsl:variable>
												<div class="RDS-Instance">
													<xsl:choose>
														<xsl:when test="./Properties/Engine = 'MySQL'">											
															<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MySQL%20DB%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
														</xsl:when>
														<xsl:when test="contains(./Properties/Engine, 'oracle')">											
															<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20Oracle%20DB%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
														</xsl:when>
														<xsl:when test="contains(./Properties/Engine, 'sqlserver')">											
															<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MS%20SQL%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
														</xsl:when>
														<xsl:otherwise>
															<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20DB%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
														</xsl:otherwise>
													</xsl:choose>
													<br /><xsl:value-of select="$publicDBinstance" />
												</div>
											</xsl:for-each>
										</xsl:for-each>
									</div>
									<br />
									Public Subnet:
									<xsl:value-of select="$subnetRef" />
								</div>
							</xsl:for-each>
						</div>
					</xsl:if>
					<!-- Count VPC Private Subnets Uniquely -->
					<xsl:variable name="privateSubnetCount">
						<xsl:value-of select="count(../*/Type[text() = 'AWS::EC2::SubnetRouteTableAssociation']/../Properties/RouteTableId/Ref[text() != $vpcPublicRouteTableRef]/../../SubnetId/Ref[not(.=preceding-sibling::item)])" />
					</xsl:variable>
					<xsl:if test="$privateSubnetCount &gt; 0">
					<div class="VPCsubnets">
						<!-- Divide Width By Number of Subnets into Integer -->
						<xsl:variable name="privateSubnetDisplayWidthPercent"><xsl:value-of select="round(100 div $privateSubnetCount) - 3" /></xsl:variable>
						<!-- Find VPC Public Subnets and Display, Assume one a single top layer-->
						<xsl:for-each select="../*/Type[text() = 'AWS::EC2::SubnetRouteTableAssociation']/../Properties/RouteTableId/Ref[text() != $vpcPublicRouteTableRef]/../../SubnetId/Ref">
							<xsl:variable name="privatesubnetRef">
								<xsl:value-of select="." />
							</xsl:variable>
							<div class="EC2-Subnet" style="width:{$privateSubnetDisplayWidthPercent}%;">
								<img src="icons/VPC_Subnet.svg" alt="Subnet" id="{$privatesubnetRef}" class="topLeftImage" />
								<!-- Private ELBs -->
								<xsl:for-each select="/*//Type[text() = 'AWS::ElasticLoadBalancing::LoadBalancer']/../Properties/Subnets/Ref[text() = $privatesubnetRef]/../../..">
									<xsl:variable name="privateELBref">
										<xsl:value-of select="name(.)" />
									</xsl:variable>
									<div class="ELB-Private">
										<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Elastic%20Load%20Balancing.svg" alt="ELB" id="{$privateELBref}" />
										<br />
										<xsl:value-of select="$privateELBref" />
									</div>
								</xsl:for-each>
								<!-- AS Groups -->
								<xsl:for-each select="/*//Type[text() = 'AWS::AutoScaling::AutoScalingGroup']/../Properties/VPCZoneIdentifier//Ref[text() = $privatesubnetRef]/../../..">
									<xsl:variable name="privateASref">
										<xsl:value-of select="name(.)" />
									</xsl:variable>
									<div class="AS-ASG">
										<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Auto%20Scaling.svg" alt="AS" class="AS-ASG-IMAGE"/>
										<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instances.svg" alt="AS" id="{$privateASref}"/>
										<br />
										<xsl:value-of select="$privateASref" />
									</div>
								</xsl:for-each>
								<!-- Instances -->
								<div class="EC2-Instances">
									<xsl:for-each select="/*//Type[text() = 'AWS::EC2::Instance']/../Properties/SubnetId//Ref[text() = $privatesubnetRef]/../../..">
										<xsl:variable name="privateInstance">
											<xsl:value-of select="name(.)" />
										</xsl:variable>
										<div class="EC2-Instance">
											<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instance.svg" alt="EC2" id="{$privateInstance}"/>
											<br /><xsl:value-of select="$privateInstance" />
										</div>
									</xsl:for-each>
								</div>
								<!-- RDS Instances -->
								<div class="RDS-Instances">
									<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBSubnetGroup']/../Properties/SubnetIds//Ref[text() = $privatesubnetRef]/../../..">
										<xsl:variable name="privateDBsubnetGroup">
											<xsl:value-of select="name(.)" />
										</xsl:variable>
										<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBInstance']/../Properties/DBSubnetGroupName//Ref[text() = $privateDBsubnetGroup]/../../..">
											<xsl:variable name="privateDBinstance">
												<xsl:value-of select="name(.)" />
											</xsl:variable>
											<div class="RDS-Instance">
												<xsl:choose>
													<xsl:when test="./Properties/Engine = 'MySQL'">											
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MySQL%20DB%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:when>
													<xsl:when test="contains(./Properties/Engine, 'oracle')">											
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20Oracle%20DB%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:when>
													<xsl:when test="contains(./Properties/Engine, 'sqlserver')">											
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MS%20SQL%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:when>
													<xsl:otherwise>
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20DB%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:otherwise>
												</xsl:choose>
												<br /><xsl:value-of select="$privateDBinstance" />
											</div>
										</xsl:for-each>
									</xsl:for-each>
								</div>
								<br />
								Private Subnet:
								<xsl:value-of select="$privatesubnetRef" />
							</div>
							
						</xsl:for-each>
					</div>
				</xsl:if>
				<!-- if a subnet is not associated with a route table, it will use the VPC default -->
				<xsl:variable name="allSubnets" select="/*//Type[text() = 'AWS::EC2::Subnet']/.."/>

				<xsl:variable name="unRefSubnet">
					<xsl:for-each select="$allSubnets">
						<xsl:variable name="testSubnetName" select="name(.)"/>
						<xsl:if test="count(/*//Type[text() = 'AWS::EC2::SubnetRouteTableAssociation']/../Properties/SubnetId/Ref[text() = $testSubnetName]) = 0">
							<xsl:text>.</xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:if test="string-length($unRefSubnet) &gt; 0">
					<div class="VPCsubnets">
						<xsl:variable name="privateSubnetDisplayWidthPercent"><xsl:value-of select="round(100 div string-length($unRefSubnet)) - 3" /></xsl:variable>
						<xsl:for-each select="$allSubnets">
						<xsl:variable name="privatesubnetRef" select="name(.)"/>
						<xsl:if test="count(/*//Type[text() = 'AWS::EC2::SubnetRouteTableAssociation']/../Properties/SubnetId/Ref[text() = $privatesubnetRef]) = 0">
							<div class="EC2-Subnet" style="width:{$privateSubnetDisplayWidthPercent}%;">
								<img src="icons/VPC_Subnet.svg" alt="Subnet" id="{$privatesubnetRef}" class="topLeftImage" />
								<!-- Private ELBs -->
								<xsl:for-each select="/*//Type[text() = 'AWS::ElasticLoadBalancing::LoadBalancer']/../Properties/Subnets/Ref[text() = $privatesubnetRef]/../../..">
									<xsl:variable name="privateELBref">
										<xsl:value-of select="name(.)" />
									</xsl:variable>
									<div class="ELB-Private">
										<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Elastic%20Load%20Balancing.svg" alt="ELB" id="{$privateELBref}" />
										<br />
										<xsl:value-of select="$privateELBref" />
									</div>
								</xsl:for-each>
								<!-- AS Groups -->
								<xsl:for-each select="/*//Type[text() = 'AWS::AutoScaling::AutoScalingGroup']/../Properties/VPCZoneIdentifier//Ref[text() = $privatesubnetRef]/../../..">
									<xsl:variable name="privateASref">
										<xsl:value-of select="name(.)" />
									</xsl:variable>
									<div class="AS-ASG">
										<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Auto%20Scaling.svg" alt="AS" class="AS-ASG-IMAGE"/>
										<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instances.svg" alt="AS" id="{$privateASref}"/>
										<br />
										<xsl:value-of select="$privateASref" />
									</div>
								</xsl:for-each>
								<!-- Instances -->
								<div class="EC2-Instances">
									<xsl:for-each select="/*//Type[text() = 'AWS::EC2::Instance']/../Properties/SubnetId//Ref[text() = $privatesubnetRef]/../../..">
										<xsl:variable name="privateInstance">
											<xsl:value-of select="name(.)" />
										</xsl:variable>
										<div class="EC2-Instance">
											<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instance.svg" alt="EC2" id="{$privateInstance}"/>
											<br /><xsl:value-of select="$privateInstance" />
										</div>
									</xsl:for-each>
								</div>
								<!-- RDS Instances -->
								<div class="RDS-Instances">
									<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBSubnetGroup']/../Properties/SubnetIds//Ref[text() = $privatesubnetRef]/../../..">
										<xsl:variable name="privateDBsubnetGroup">
											<xsl:value-of select="name(.)" />
										</xsl:variable>
										<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBInstance']/../Properties/DBSubnetGroupName//Ref[text() = $privateDBsubnetGroup]/../../..">
											<xsl:variable name="privateDBinstance">
												<xsl:value-of select="name(.)" />
											</xsl:variable>
											<div class="RDS-Instance">
												<xsl:choose>
													<xsl:when test="./Properties/Engine = 'MySQL'">											
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MySQL%20DB%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:when>
													<xsl:when test="contains(./Properties/Engine, 'oracle')">											
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20Oracle%20DB%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:when>
													<xsl:when test="contains(./Properties/Engine, 'sqlserver')">											
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MS%20SQL%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:when>
													<xsl:otherwise>
														<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20DB%20Instance.svg" alt="RDS" id="{$privateDBinstance}"/>
													</xsl:otherwise>
												</xsl:choose>
												<br /><xsl:value-of select="$privateDBinstance" />
											</div>
										</xsl:for-each>
									</xsl:for-each>
								</div>
								<br />
								Private Subnet:
								<xsl:value-of select="$privatesubnetRef" />
							</div>
						</xsl:if>
					</xsl:for-each>
					</div>
				</xsl:if>
					<div class="vpc-footer">
						VPC:
						<xsl:value-of select="$vpcRefName" />
				</div>
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="novice-template">
		<div class="novice">
			<!-- Public ELBs -->
			<xsl:for-each select="/*//Type[text() = 'AWS::ElasticLoadBalancing::LoadBalancer']/..">
				<xsl:variable name="publicELBref">
					<xsl:value-of select="name(.)" />
				</xsl:variable>
				<div class="ELB-Public">
					<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Elastic%20Load%20Balancing.svg" alt="ELB" id="{$publicELBref}" />
					<br />
					<xsl:value-of select="$publicELBref" />
				</div>
			</xsl:for-each>
			<!-- ASG -->
			<xsl:for-each select="/*//Type[text() = 'AWS::AutoScaling::AutoScalingGroup']/..">
				<xsl:variable name="publicASref">
					<xsl:value-of select="name(.)" />
				</xsl:variable>
				<div class="AS-ASG">
					<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Auto%20Scaling.svg" alt="AS" id="{$publicASref}" class="AS-ASG-IMAGE"/>
					<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instances.svg" alt="AS" id="{$publicASref}"/>
					<br />
					<xsl:value-of select="$publicASref" />
				</div>
			</xsl:for-each>
			<div class="EC2-Instances">
				<!-- Instances -->
				<xsl:for-each select="/*//Type[text() = 'AWS::EC2::Instance']/..">
					<xsl:variable name="publicInstance">
						<xsl:value-of select="name(.)" />
					</xsl:variable>
					<div class="EC2-Instance">
						<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Instance.svg" alt="EC2" id="{$publicInstance}"/>
						<!-- Look for EIP -->
						<xsl:for-each select="/*//Type[text() = 'AWS::EC2::EIP']/../Properties/InstanceId//Ref[text() = $publicInstance]/../../..">
							<img src="icons/AWS_Simple_Icons_svg_eps/Compute%20&amp;%20Networking/SVG/Compute%20&amp;%20Networking%20copy_Amazon%20EC2%20Elastic%20IP.svg" alt="EIP" class="EIP"/>
						</xsl:for-each>
						<br /><xsl:value-of select="$publicInstance" />
					</div>
				</xsl:for-each>
				<!-- RDS Instances -->
				<div class="RDS-Instances">
					<xsl:for-each select="/*//Type[text() = 'AWS::RDS::DBInstance']/..">
						<xsl:variable name="publicDBinstance">
							<xsl:value-of select="name(.)" />
						</xsl:variable>
						<div class="RDS-Instance">
							<xsl:choose>
								<xsl:when test="./Properties/Engine = 'MySQL'">											
									<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MySQL%20DB%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
								</xsl:when>
								<xsl:when test="contains(./Properties/Engine, 'oracle')">											
									<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20Oracle%20DB%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
								</xsl:when>
								<xsl:when test="contains(./Properties/Engine, 'sqlserver')">											
									<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20MS%20SQL%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
								</xsl:when>
								<xsl:otherwise>
									<img src="icons/AWS_Simple_Icons_svg_eps/Database/SVG/Database%20copy_Amazon%20RDS%20DB%20Instance.svg" alt="RDS" id="{$publicDBinstance}"/>
								</xsl:otherwise>
							</xsl:choose>
							<br /><xsl:value-of select="$publicDBinstance" />
						</div>
					</xsl:for-each>
				</div>
			</div>
		</div>
	</xsl:template>
	
</xsl:stylesheet>
