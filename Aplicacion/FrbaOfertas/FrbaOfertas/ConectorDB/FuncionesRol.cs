﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FrbaOfertas.Modelo.Roles;
using System.Data;
using FrbaOfertas.BaseDeDatos;
using System.Data.SqlClient;

namespace FrbaOfertas.ConectorDB
{
    class FuncionesRol
    {
        public static List<String> ObtenerFuncionalidadesDeUnRol(string nombreRol)
        {
            List<String> lista = new List<string>();

            return lista;

        }

        public static List<String> ObtenerRolesDeUnUsuario(int id_usuario)
        {
            List<String> lista = new List<string>();
            return lista;



        }
        public static List<String> ObtenerRolesRegistrables()
        {
            List<String> lista = new List<string>();
            lista.Add("Proveedor");
            lista.Add("Cliente");
            lista.Add("Administrativo");
            return lista;

        }
        public static Boolean existeRol(string rol)
        {
            return false;

        }

        public static void GuardarRol(String Rol, List<String> listaFunciones)
        {

        }

        public static void BajaLogicaRol(int idRol)
        {

            SqlConnection con = new SqlConnection(Conexion.getStringConnection());
            con.Open();
            SqlCommand cmd = new SqlCommand("UPDATE ROLES SET BAJA_LOGICA = 1 WHERE ROL_ID =" + idRol, con);
            cmd.ExecuteNonQuery();

        }
        public static void invertirBajaLogicaRol(int rolID)
        {
            SqlConnection con = new SqlConnection(Conexion.getStringConnection());
            con.Open();
            SqlCommand cmd = new SqlCommand("UPDATE ROLES SET BAJA_LOGICA = 0 WHERE ROL_ID =" + rolID, con);
            cmd.ExecuteNonQuery();
        }
        public static string ObtenerDetalleRol(int Id)
        {
            return "Error";

        }
        public static Boolean ObtenerEstadoRol(int Id)
        {
            return false;
        }

        public static void UpdatearRol(String RolNuevo, String Rol, bool habilitado, List<String> listaFunciones)
        {

        }
    }
}
