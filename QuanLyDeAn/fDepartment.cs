﻿using QuanLyDeAn.DAO;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QuanLyDeAn
{
    public partial class fDepartment : Form
    {
        BindingSource listDepartment = new BindingSource();

        public fDepartment()
        {
            InitializeComponent();
            LoadData();
        }

        void LoadData()
        {
            dtgvDepartment.DataSource = listDepartment;
            LoadListDepartment();
            AddDepartmentIDBinding();
            AddDepartmentNameBinding();
            AddDepartmentHeadIDBinding();
        }

        void LoadListDepartment()
        {
            listDepartment.DataSource = DepartmentDAO.Instance.GetListDepartment();
        }

        void AddDepartmentIDBinding()
        {
            txbDepartmentID.DataBindings.Add(new Binding("Text", dtgvDepartment.DataSource, "MAPB", true, DataSourceUpdateMode.Never));
        }

        void AddDepartmentNameBinding()
        {
            txbDepartmentName.DataBindings.Add(new Binding("Text", dtgvDepartment.DataSource, "TENPB", true, DataSourceUpdateMode.Never));
        }

        void AddDepartmentHeadIDBinding()
        {
            txbDepartmentHeadID.DataBindings.Add(new Binding("Text", dtgvDepartment.DataSource, "TRPHG", true, DataSourceUpdateMode.Never));
        }

        private void btnAddDepartment_Click(object sender, EventArgs e)
        {
            string departmentID = txbDepartmentID.Text;
            string departmentName = txbDepartmentName.Text;
            string departmentHeadID = txbDepartmentHeadID.Text;

            if (departmentID == "" || departmentName == "")
            {
                MessageBox.Show("Vui lòng điền đầy đủ mã và tên phòng ban khi khởi tạo phòng ban!");
            }
            else
            {
                if (DepartmentDAO.Instance.CreateDepartment(departmentID, departmentName, departmentHeadID))
                {
                    MessageBox.Show("Thêm phòng ban thành công!");
                    LoadListDepartment();
                }
                else
                {
                    MessageBox.Show("Phòng ban đã tồn tại!");
                }
            }
        }
    }
}